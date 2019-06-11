Configuration WebServerConfiguration
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -Module xWebAdministration

    Node $AllNodes.NodeName
    {
        # loop through features list and install
        ForEach($Feature in $Node.WindowsFeatures)
        {
            WindowsFeature "$($Feature.Name)"
            {
                Ensure = $Feature.Ensure
                Name = $Feature.Name
                Source = $Feature.Source # Needed if for some reason the resource isn't on the OS already and needs to be retrieved from something like a mounted ISO
            }
        }

        # stop default web site
        xWebSite DefaultSite
        {
            Ensure = "Absent"
            Name = "Default Web Site"
            State = "Stopped"
            PhysicalPath = "c:\inetpub\wwwroot"
            DependsOn = "[WindowsFeature]Web-Server"
        }

        # loop through list of default app pools and stop them
        ForEach($Pool in @(".NET v2.0", `
        ".NET v2.0 Classic", `
        ".NET v4.5", `
        ".NET v4.5 Classic", `
        "Classic .NET AppPool", `
        "DefaultAppPool"))
        {
            xWebAppPool $Pool
            {
                Name = $Pool
                State = "Stopped"
                Ensure = "Absent"				 
                DependsOn = "[WindowsFeature]Web-Server"
            }
        }

        # make sure log path exists
        File LoggingPath
        {
            Type = "Directory"
            DestinationPath = $Node.LogPath
            Ensure = "Present"
        }

        # loop through the sites
        ForEach($Site in $Node.Sites)
        {
            # create the folder
            File $Site.Name
            {
                Type = "Directory"
                DestinationPath = "$($Node.Rootpath)\$($Site.Name)"
                Ensure = $(if ($Site.Ensure) {$Site.Ensure} else {"Present"})
            }

            # create the site app pool
            xWebAppPool $Site.Name
            {
                Name = $(if($Site.Pool.Name) {$Site.Pool.Name} else {$Site.Name})
                Ensure = $(if ($Site.Ensure) {$Site.Ensure} else {"Present"})
                ManagedPipelineMode = "$($Site.Pool.Pipeline)"
                managedRuntimeVersion = "$($Site.Pool.RuntimeVersion)"
                State = $Site.Pool.State
                IdentityType = $(if ($Site.Pool.IdentityType) {$Site.Pool.IdentityType} else {"ApplicationPoolIdentity"})
                Credential = $(if (($Credentials | Where-Object {$_.Name -eq "$($Site.Name).AppPoolIdentity"}) -ne $null) {($Credentials | Where-Object {$_.Name -eq "$($Site.Name).AppPoolIdentity"}).Credential} else {$null} )
            }
            
            # create the site
            xWebSite $Site.Name
            {
                Ensure = $(if ($Site.Ensure) {$Site.Ensure} else {"Present"})
                Name = $Site.Name
                State = $Site.State
                PhysicalPath = "$($Node.Rootpath)\$($Site.Name)"
                ApplicationPool = $(if($Site.Pool.Name) {$Site.Pool.Name} else {$Site.Name})
                BindingInfo = @(
                    # loop through the binding information
                    ForEach($BindingInfo in $Site.BindingInformation)
                    {
                    # check for keyword CertificateStoreName
                        MSFT_xWebBindingInformation
                        {
                            Port = $BindingInfo.Port
                            IPAddress  = $BindingInfo.IPAddress
                            Protocol = $BindingInfo.Protocol
                        }                   
                    }
                )

                # Set logging path
                LogPath = $Node.LogPath

                # Set Authentication mechanisms
                AuthenticationInfo = MSFT_xWebAuthenticationInformation {
                    Anonymous = $Site.Authentication.Anonymous
                    Basic = $Site.Authentication.Basic
                    Digest = $Site.Authentication.Digest
                    Windows = $Site.Authentication.Windows
				}
            }

            # Loop through site application collection and create folders
            ForEach($Application in $Site.Applications)
            {
                File "$($Site.Name)-$($Application.Name)"
                {
                    Type = "Directory"
                    DestinationPath = "$($Node.Rootpath)\$($Site.Name)\$($Application.FolderName)"
                    Ensure = $(if ($Application.Ensure) {$Application.Ensure} else {"Present"})
                    Force = $true
                }


                # create application pool
                xWebAppPool $Application.Name
                {
                    Name = $(if($Application.Pool.Name) {$Application.Pool.Name} else {$Application.Name})
                    Ensure = $(if ($Application.Ensure) {$Application.Ensure} else {"Present"})
                    State = $Application.Pool.State
                    ManagedPipelineMode = $Application.Pool.Pipeline
                    managedRuntimeVersion = "$($Application.Pool.RuntimeVersion)"
                    idleTimeout = $Application.Pool.IdleTimeout
                    restartTimeLimit = $Application.Pool.RestartTimeLimit
                    IdentityType = $(if ($Application.Pool.IdentityType) {$Application.Pool.IdentityType} else {"ApplicationPoolIdentity"})
                    Credential = $(if (($Credentials | Where-Object {$_.Name -eq "$($Application.Name).AppPoolIdentity"}) -ne $null) {($Credentials | Where-Object {$_.Name -eq "$($Application.Name).AppPoolIdentity"}).Credential} else {$null} )
                }

                # create application
                xWebApplication $Application.Name
                {
                    #Name = $Application.Name
					Name = $(if($Application.Name -eq $Application.FolderName) {$Application.Name} else {$Application.FolderName.Replace("\", "/")})
                    Website = $Site.Name
                    WebAppPool = $(if($Application.Pool.Name) {$Application.Pool.Name} else {$Application.Name})
                    PhysicalPath = "$($Node.Rootpath)\$($Site.Name)\$($Application.FolderName)"
                    Ensure = $(if ($Application.Ensure) {$Application.Ensure} else {"Present"})
					# Set Authentication mechanisms
					AuthenticationInfo = MSFT_xWebApplicationAuthenticationInformation {
						Anonymous = $Application.Authentication.Anonymous
						Basic = $Application.Authentication.Basic
						Digest = $Application.Authentication.Digest
						Windows = $Application.Authentication.Windows
					}
                }
            }
        }
    }
}

# create credential object
$Credentials = @()

WebServerConfiguration -ConfigurationData "C:\DscConfiguration\WebServer.psd1" -OutputPath "C:\DscConfiguration"

Start-DscConfiguration -Wait -Verbose -Path "C:\DscConfiguration"