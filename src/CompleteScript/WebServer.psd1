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
					Name = "Web-Mgmt-Tools"
					Ensure = "Present"
					Source = "d:\sources\sxs"
				},
				@{
					Name = "Web-Default-Doc"
					Ensure = "Present"
					Source = "d:\sources\sxs"
				},
				@{
					Name = "Web-Http-Errors"
					Ensure = "Present"
					Source = "d:\sources\sxs"
				},
				@{
					Name = "Web-Static-Content"
					Ensure = "Present"
					Source = "d:\sources\sxs"
				},
				@{
					Name = "Web-Http-Logging"
					Ensure = "Present"
					Source = "d:\sources\sxs"
				},
				@{
					Name = "Web-ISAPI-Ext"
					Ensure = "Present"
					Source = "d:\sources\sxs"
				},
				@{
					Name = "Web-ISAPI-Filter"
					Ensure = "Present"
					Source = "d:\sources\sxs"
				},
				@{
					Name = "Web-Asp-Net45"
					Ensure = "Present"
					Source = "d:\sources\sxs"
				},
				@{
					Name = "Web-Asp-Net"
					Ensure = "Present"
					Source = "d:\sources\sxs"
				},
				@{
					Name = "Web-Http-Redirect"
					Ensure = "Present"
					Source = "d:\sources\sxs"
				},
				@{
					Name = "Web-Http-Tracing"
					Ensure = "Present"
					Source = "d:\sources\sxs"
				},
				@{
					Name = "Web-Windows-Auth"
					Ensure = "Present"
					Source = "d:\sources\sxs"
				}
			)

			# default IIS Site log path
			LogPath = "#{Project.LogPath}"

			# Define root path for IIS Sites
			RootPath = "C:\inetpub\wwwroot"

            # define IIS Sites
            Sites = @(
                @{
					Name = "OctopusDeploy.com"
					Ensure = "Present"
					State = "Started"
					BindingInformation = @(
						@{
							Port = "80"
							IPAddress = "" # leave blank or comment out to set to All Unassigned
							Protocol = "HTTP"
						}
					)
					Pool = @{
							PipeLine = "Integrated"
							RuntimeVersion = "v4.0"
							State = "Started"
						}
					Applications = @(
						@{
							Name = "OctoFX"
							FolderName = "OctoFX"
							Ensure = "Present"
							Pool = @{
								Pipeline = "Integrated"
								RuntimeVersion = "v4.0"
								State = "Started"
							}
							Authentication = @{
								Windows = $false
								Anonymous = $true
							}
	
						},
						@{
							Name = "OctopusPetShop"
							FolderName = "OctopusPetShop"
							Ensure = "Present"
							Pool = @{
								Pipeline = "Integrated"
								RuntimeVersion = "v4.0"
								State = "Started"
							}
						}
					)
				}
            )

            # fill in this section to enable or disable encryption protocols, hashes, ciphers, and specify cipher suite ordering
            Encryption = @{
				Ciphers = @(
					@{
						Name = "DES 56/56"
						Enabled = "0" # Disabled = 0, Enabled = -1
					},
					@{
						Name = "NULL"
						Enabled = "0"
					},
					@{
						Name = "RC2 128/128"
						Enabled = "0"
					},
					@{
						Name = "RC2 40/128"
						Enabled = "0"
					},
					@{
						Name = "RC2 56/128"
						Enabled = "0"
					},
					@{
						Name = "RC4 64/128"
						Enabled = "0"
					},
					@{
						Name = "AES 128/128"
						Enabled = "-1"
					},
					@{
						Name = "AES 256/256"
						Enabled = "-1"
					},
					@{
						Name = "Triple DES 168/168"
						Enabled = "-1"
					},
					@{
						Name = "RC4 40/128"
						Enabled = "0"
					},
					@{
						Name = "RC4 56/128"
						Enabled = "0"
					},
					@{
						Name = "RC4 128/128"
						Enabled = "0"
					}
				)
				Hashes = @(
					@{
						Name = "MD5"
						Enabled = "0"
					},
					@{
						Name = "SHA"
						Enabled = "0"
					},
					@{
						Name = "SHA256"
						Enabled = "-1"
					},
					@{
						Name = "SHA384"
						Enabled = "-1"
					},
					@{
						Name = "SHA512"
						Enabled = "-1"
					}
				)
				Protocols = @(
					@{
						Name = "Multi-Protocol Unified Hello"
						Enabled = "0"
					},
					@{
						Name = "PCT 1.0"
						Enabled = "0"
					},
					@{
						Name = "SSL 2.0"
						Enabled = "0"
					},
					@{
						Name = "SSL 3.0"
						Enabled = "0"
					},
					@{
						Name = "TLS 1.0"
						Enabled = "0"
					},
					@{
						Name = "TLS 1.1"
						Enabled = "-1"
					},
					@{
						Name = "TLS 1.2"
						Enabled = "-1"
					}
				)
				KeyExchanges = @(
					@{
						Name = "Diffie-Hellman"
						Enabled = "-1"
					},
					@{
						Name = "ECDH"
						Enabled = "-1"
					},
					@{
						Name = "PKCS"
						Enabled = "-1"
					}
				)
				CipherSuiteOrder = @("TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256", "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384", "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256", "TLS_RSA_WITH_AES_256_GCM_SHA384", "TLS_RSA_WITH_AES_128_GCM_SHA256", "TLS_RSA_WITH_AES_256_CBC_SHA256", "TLS_RSA_WITH_AES_128_CBC_SHA256")
			}
		}
    )
}