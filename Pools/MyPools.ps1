param(
    [Parameter(Mandatory = $true)]
    [String]$Querymode = $null,
    [Parameter(Mandatory = $false)]
    [pscustomobject]$Info
)


$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName
$ActiveOnManualMode = $true
$ActiveOnAutomaticMode = $false
$AbbName = 'MY'
$WalletMode = "NONE"
$RewardType = "PPLS"
$Result = @()


if ($Querymode -eq "info") {
    $Result = [PSCustomObject]@{
        Disclaimer            = "Must set wallet for each coin on web, set login on config.txt file"
        ActiveOnManualMode    = $ActiveOnManualMode
        ActiveOnAutomaticMode = $ActiveOnAutomaticMode
        ApiData               = $true
        AbbName               = $AbbName
        WalletMode            = $WalletMode
        RewardType            = $RewardType
    }
}


if (($Querymode -eq "core" ) -or ($Querymode -eq "Menu")) {
    $Pools = @()

    # $Pools += [pscustomobject]@{"coin" = "Aeon"; "algo" = "CryptoLight"; "symbol" = "AEON"; "server" = "mine.aeon-pool.com"; "port" = 5555; "fee" = 0.01; "User" = $CoinsWallets.get_item('AEON')}
    # $Pools += [pscustomobject]@{"coin" = "HPPcoin"; "algo" = "Lyra2h"; "symbol" = "HPP"; "server" = "pool.hppcoin.com"; "port" = 3008; "fee" = 0; "User" = "$Username.#Workername#"}
    # $Pools += [pscustomobject]@{"coin" = "HPPcoin"; "algo" = "Lyra2h"; "symbol" = "HPP"; "server" = "hpp-mine.idcray.com"; "port" = 10111; "fee" = 0.01; "User" = "$Username.#Workername#"}
    $Pools += [pscustomobject]@{"coin" = "ETHEREUMCLASIC"; "algo" = "ETHASH"; "symbol" = "ETC"; "server" = "eu1-etc.ethermine.org"; "port" = 4444; "fee" = 0.01; "User" = $CoinsWallets.get_item('ETC') + ".#Workername#"; "location"="EUROPE"}
    $Pools += [pscustomobject]@{"coin" = "ETHEREUM"; "algo" = "ETHASH"; "symbol" = "ETH"; "server" = "eu1.ethermine.org"; "port" = 4444; "fee" = 0.01; "User" = $CoinsWallets.get_item('ETH') + ".#Workername#"; "location"="EUROPE"}
    $Pools += [pscustomobject]@{"coin" = "ZCASH"; "algo" = "Equihash"; "symbol" = "ZEC"; "server" = "eu1-zcash.flypool.org"; "port" = 3333; "fee" = 0.01; "User" = $CoinsWallets.get_item('ZEC') + ".#Workername#"; "location"="EUROPE"}
    $Pools += [pscustomobject]@{"coin" = "Verge"; "algo" = "blake2s"; "symbol" = "XVG"; "server" = "xvg.antminepool.com"; "port" = 9008; "fee" = 0.005; "User" = $CoinsWallets.get_item('XVG'); Pass = "c=XVG"; "location"="EUROPE"}
    #$Pools += [pscustomobject]@{"coin" = "Luxcoin"; "algo" = "phi"; "symbol" = "LUX"; "server" = "pool.bsod.pw"; "port" = 6667; "fee" = 0.009; "User" = $CoinsWallets.get_item('LUX'); Pass = "c=LUX"; "location"="EUROPE"}
    #$Pools += [pscustomobject]@{"coin" = "Luxcoin"; "algo" = "phi"; "symbol" = "LUX"; "server" = "eu1.altminer.net"; "port" = 11000; "fee" = 0.009; "User" = $CoinsWallets.get_item('LUX') + ".#Workername#"; Pass = "c=LUX"; "location"="EUROPE"}

    $Pools |ForEach-Object {
        $Result += [PSCustomObject]@{
            Algorithm             = $_.Algo
            Info                  = $_.Coin
            Protocol              = "stratum+tcp"
            Host                  = $_.Server
            Port                  = $_.Port
            User                  = $_.User
            Pass                  = if ([string]::IsNullOrEmpty($_.Pass)) {"x"} else {$_.Pass}
            Location              = if ([string]::IsNullOrEmpty($_.Location)) {"EUROPE"} else {$_.Location}
            SSL                   = $false
            Symbol                = $_.symbol
            AbbName               = $AbbName
            ActiveOnManualMode    = $ActiveOnManualMode
            ActiveOnAutomaticMode = $ActiveOnAutomaticMode
            PoolName              = $Name
            WalletMode            = $WalletMode
            Fee                   = $_.Fee
            RewardType            = $RewardType
        }
    }
    remove-variable Pools
}


$Result |ConvertTo-Json | Set-Content $info.SharedFile
remove-variable result
