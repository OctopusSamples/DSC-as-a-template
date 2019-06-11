@{
    AllNodes =  @(
        @{
            
            # node name
            NodeName = $env:COMPUTERNAME
            
            # required windows features
            WindowsFeatures = @(
				@{
					Name = "Web-Server" 
					Ensure = "Present"
					Source = "d:\sources\sxs"
				},
				@{
					Name = "Web-Asp-Net45"
					Ensure = "Present"
					Source = "d:\sources\sxs"
				}
			)
		}
    )
}