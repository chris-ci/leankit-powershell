function Get-LeanKitBoard{
    [CmdletBinding()]
    [OutputType([array])]
    param(
        # URL of the leankit account
        [Parameter(ParameterSetName='Credential')]
        [string]$URL,
        
        # PSCredentialsObject with the username and password needed to auth against leankit
        [Parameter(ParameterSetName='Credential')]
        [alias('credentials')]
        [pscredential]$credential,
        
        # Name of the profile to load
        [Parameter(ParameterSetName='Profile')]
        [string]$ProfileName,

        # ID of the board we want to get
        [parameter(mandatory=$true)]
        [int]$BoardID
    )

    # Try and get defaults and break out of the function with a null value if we can't
    if(!($private:LeanKitAccount = Merge-LeanKitProfileDataWithExplicitParams -ProfileData $(Get-LeanKitProfile) -ExplicitParams $PsBoundParameters)){
        return;
    }
    
    # Call out to LeanKit to get the data
    [string]$private:uri = $private:LeanKitAccount.URL + "/Kanban/Api/Boards/$private:boardID/"
    $private:Board = $(Invoke-RestMethod -Uri $private:uri  -Credential $private:LeanKitAccount.Credential).ReplyData

    #Debug 
    $global:Board = $private:Board.clone()

    # Add the custom type to each card to enable a default view
    $private:Board | %{$_.psobject.TypeNames.Insert(0, "PSLeanKit.Board")}
    $private:Board.Lanes | %{$_.psobject.TypeNames.Insert(0, "PSLeanKit.Lane")}
    if($private:Board.Lanes.cards){
        $private:Board.Lanes.cards | %{$_.psobject.TypeNames.Insert(0, "PSLeanKit.Card")}
    }
    if($private:Board.Archive){
        $private:Board.Archive | %{$_.psobject.TypeNames.Insert(0, "PSLeanKit.Card")}
    }
    if($private:Board.Backlog.Cards){
        $private:Board.Backlog.Cards | %{$_.psobject.TypeNames.Insert(0, "PSLeanKit.Card")}
    }
    $private:Board.CardTypes | %{$_.psobject.TypeNames.Insert(0, "PSLeanKit.CardType")}

    return $private:Board
}


<#
.SYNOPSIS
    Lists all boards you have access to in your account
#>

function Find-LeanKitBoard{
    [CmdletBinding(DefaultParameterSetName='Credentials' )]
    [OutputType([array])]
    param(
        # URL of the leankit account
        [Parameter(ParameterSetName='Credential')]
        [string]$URL,
        
        # PSCredentialsObject with the username and password needed to auth against leankit
        [Parameter(ParameterSetName='Credential')]
        [alias('credentials')]
        [pscredential]$credential,
        
        # Name of the profile to load
        [Parameter(ParameterSetName='Profile')]
        [string]$ProfileName
    )

    # Try and get defaults and break out of the function with a null value if we can't
    if(!($private:LeanKitAccount = Merge-LeanKitProfileDataWithExplicitParams -ProfileData $(Get-LeanKitProfile) -ExplicitParams $PsBoundParameters)){
        return;
    }

    [string]$private:uri = $private:LeanKitAccount.URL + "/Kanban/Api/Boards/"
    return $(Invoke-RestMethod -Uri $private:uri  -Credential $private:LeanKitAccount.credential).ReplyData
}

<#
.SYNOPSIS
    Gets all cards in a given board
#>
function Get-LeanKitCardsInBoard{
    [CmdletBinding()]
    [OutputType([array])]
    param(
         # URL of the leankit account
        [Parameter(ParameterSetName='Credential')]
        [string]$URL,

        # PSCredentialsObject with the username and password needed to auth against leankit
        [Parameter(ParameterSetName='Credential')]
        [alias('credentials')]
        [pscredential]$credential,
        
        # Name of the profile to load
        [Parameter(ParameterSetName='Profile')]
        [string]$ProfileName,
        
        # ID of the board to fetch cards from
        [parameter(mandatory=$true)]
        [int]$BoardID
    )

    # Pass any common parameters on to the superordinate cmdlet
    $private:Params = Merge-LeanKitProfileDataWithExplicitParams -ExplicitParams $PsBoundParameters
    
    # Get the board
    $private:Params.BoardID = $private:BoardID;
    $private:Board = Get-LeanKitBoard @params

    # Gather all the cards from the board
    $private:Cards = @($private:Board.Lanes.cards) + @($private:Board.Archive) + @($private:Board.Backlog.Cards);
    
    # Add the custom type to each card to enable a default view
    $private:Cards | %{$_.psobject.TypeNames.Insert(0, "PSLeanKit.Card")}

    return [array]$private:Cards
}
