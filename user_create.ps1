# Import necessary module
Import-Module AzureAD

# Authenticate with Azure AD
$cred = Get-Credential
Connect-AzureAD -Credential $cred

# Path to the CSV file
$csvPath = "C:\path\to\your\users.csv"

# Specify the group name or ObjectId to which users will be added
$groupNameOrObjectId = "YourGroupName" # Replace with your group name or ObjectId

# Import CSV and iterate through each row
$userList = Import-Csv -Path $csvPath

foreach ($user in $userList) {
    # Define user parameters
    $userParams = @{
        DisplayName = "$($user.FirstName) $($user.LastName)"
        UserPrincipalName = $user.UserPrincipalName
        MailNickname = $user.UserPrincipalName.Split("@")[0]
        AccountEnabled = $true
        PasswordProfile = @{
            Password = $user.Password
            ForceChangePasswordNextSignIn = $false
        }
    }

    # Create the user
    $newUser = New-AzureADUser @userParams

    if ($newUser) {
        Write-Host "Created user: $($user.UserPrincipalName)"

        # Get the group
        $group = Get-AzureADGroup -Filter "DisplayName eq '$groupNameOrObjectId'"

        if ($group) {
            # Add user to the group
            Add-AzureADGroupMember -ObjectId $group.ObjectId -RefObjectId $newUser.ObjectId
            Write-Host "Added $($user.UserPrincipalName) to group: $($group.DisplayName)"
        } else {
            Write-Host "Group not found: $groupNameOrObjectId"
        }
    } else {
        Write-Host "Failed to create user: $($user.UserPrincipalName)"
    }
}

# Disconnect from Azure AD
Disconnect-AzureAD
