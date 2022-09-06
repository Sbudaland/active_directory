# active directory lab
Windows AD Lab Tutorial notes and resources

1. Use 'sconfig'to:
    - Change the hostname
    - Change the IP address to static
    - Change the DNS server to own IP address

2. Install the Active Directory Windows Feature

'''shell
Install-WindowsFeature AD-Domain-Serives -IncludeManagementTools
'''

'''
Get-NetIPAddress
'''

# Joining the workstation to the domain


'''
Add-Computer -Domainname xyz.com -Credential xyz\Administrator
-Force -Restart
'''
