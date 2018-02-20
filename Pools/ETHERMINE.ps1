param(
    [Parameter(Mandatory = $false)]
    [String]$Querymode = $null,
    [Parameter(Mandatory = $false)]
    [pscustomobject]$Info
    )

#. .\Include.ps1

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName
$ActiveOnManualMode    = $true
$ActiveOnAutomaticMode = $true
$ActiveOnAutomatic24hMode=$false
$AbbName = 'ETHM'
$WalletMode="WALLET"
$Result=@()
$RewardType='PPLS'

if ($Querymode -eq "info"){
    $Result = [PSCustomObject]@{
                    Disclaimer = "No registration, No autoexchange, need wallet for each coin on config.txt"
                    ActiveOnManualMode=$ActiveOnManualMode  
                    ActiveOnAutomaticMode=$ActiveOnAutomaticMode
                    ActiveOnAutomatic24hMode=$ActiveOnAutomaticMode
                    ApiData = $true
                    AbbName=$AbbName
                    WalletMode=$WalletMode
                    RewardType=$RewardType
                          }
    }



    
    
     
#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************
    

if ($Querymode -eq "SPEED")    {
      
    
    try {
        #$http="https://api.nanopool.org/v1/"+$Info.symbol.tolower()+"/history/"+$Info.user
		switch ($Info.symbol.tolower()){
            "eth"{$http="https://api.ethermine.org/miner/"+$Info.user+"/currentStats"}
            "etc"{$http="https://api-etc.ethermine.org/miner/"+$Info.user+"/currentStats"}
            "zec"{$http="https://api-zcash.flypool.org/miner/"+$Info.user+"/currentStats"}
        }

        $Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 5 | ConvertFrom-Json 

        if ($Request.data -ne "") {
                $Result=[PSCustomObject]@{
                    PoolName =$name
                    Workername = $Info.WorkerName
                    Hashrate = $Request.data.currentHashrate
                }
        }
    }
    catch {}


    
}




#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************
    

    if ($Querymode -eq "WALLET")    {
      
    
                                try {
                                    #$http="https://api.nanopool.org/v1/"+$Info.symbol.tolower()+"/balance/"+$Info.user
									switch ($Info.symbol.tolower()){
										"eth"{$http="https://api.ethermine.org/miner/"+$Info.user+"/currentStats"}
										"etc"{$http="https://api-etc.ethermine.org/miner/"+$Info.user+"/currentStats"}
										"zec"{$http="https://api-zcash.flypool.org/miner/"+$Info.user+"/currentStats"}
									}
                                    $Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 5 | ConvertFrom-Json 
                                }
                                catch {}

                        
                                $Result=[PSCustomObject]@{
                                                        Pool =$name
                                                        currency = $Info.OriginalCoin														
                                                        balance = $Request.data.unpaid / 1000000000000000000
                                                    }
                        }

                        

#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************


if (($Querymode -eq "core" ) -or ($Querymode -eq "Menu")){

        $Pools=@()
        $Pools +=[pscustomobject]@{"symbol"="ZEC"; "algo"="Equihash";"port"=3333;"coin"="ZCASH";"location"="US";"server"="us1-zcash.flypool.org"; "fee"=0.01}
        $Pools +=[pscustomobject]@{"symbol"="ZEC"; "algo"="Equihash";"port"=3333;"coin"="ZCASH";"location"="ASIA";"server"="asia1-zcash.flypool.org"; "fee"=0.01}
        $Pools +=[pscustomobject]@{"symbol"="ZEC"; "algo"="Equihash";"port"=3333;"coin"="ZCASH";"location"="EUROPE";"server"="eu1-zcash.flypool.org"; "fee"=0.01}
        $Pools +=[pscustomobject]@{"symbol"="ETH"; "algo"="ETHASH";"port"=4444;"coin"="ETHEREUM";"location"="US";"server"="us1.ethermine.org"; "fee"=0.01}
        $Pools +=[pscustomobject]@{"symbol"="ETH"; "algo"="ETHASH";"port"=4444;"coin"="ETHEREUM";"location"="ASIA";"server"="asia1.ethermine.org"; "fee"=0.01}
        $Pools +=[pscustomobject]@{"symbol"="ETH"; "algo"="ETHASH";"port"=4444;"coin"="ETHEREUM";"location"="EUROPE";"server"="eu1.ethermine.org"; "fee"=0.01}
        $Pools +=[pscustomobject]@{"symbol"="ETC"; "algo"="ETHASH";"port"=4444;"coin"="ETHEREUMCLASIC";"location"="US";"server"="us1-etc.ethermine.org"; "fee"=0.01}
        $Pools +=[pscustomobject]@{"symbol"="ETC"; "algo"="ETHASH";"port"=4444;"coin"="ETHEREUMCLASIC";"location"="EUROPE";"server"="eu1-etc.ethermine.org"; "fee"=0.01}

     


        $Pools |  ForEach-Object {
		
			$Wallet = $CoinsWallets.get_item($_.symbol)
			if ($Wallet -ne $null -and $Wallet -ne "") {

                try {
                    $RequestW=$null
					switch ($_.symbol.tolower()){
						"eth"{ $http="https://api.ethermine.org/poolStats";	$Divisor = 1000000}
						"etc"{ $http="https://api-etc.ethermine.org/poolStats"; $Divisor = 1000000}
						"zec"{ $http="https://api-zcash.flypool.org/poolStats";	$Divisor = 1}
					}
                    $RequestW = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 3 | ConvertFrom-Json 
                    $RequestP=$null
                    $http="https://api.nanopool.org/v1/"+$_.Symbol.ToLower()+"/approximated_earnings/1"
                    $RequestP = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 3 | ConvertFrom-Json |select-object -ExpandProperty data |select-object -ExpandProperty day
                }
                catch {}

               
                    $Result+=[PSCustomObject]@{
                                Algorithm     = $_.algo
                                Info          = $_.Coin
                                Price         = ($RequestP.bitcoins / $Divisor)
                                Price24h      = $null
                                Protocol      = "stratum+tcp"
                                Host          = $_.server
                                Port          = $_.port
                                User          = $Wallet + ".#WorkerName#"
                                Pass          = "x"
                                Location      = $_.location
                                SSL           = $false
                                Symbol        = $_.symbol
                                AbbName       = $AbbName
                                ActiveOnManualMode    = $ActiveOnManualMode
                                ActiveOnAutomaticMode = $ActiveOnAutomaticMode
                                PoolWorkers   = $RequestW.data.poolStats.workers
                                PoolHashRate  = $RequestW.data.poolStats.hashRate
                                Blocks_24h    = $null
                                WalletMode    = $WalletMode
                                WalletSymbol    = $_.symbol
                                PoolName = $Name
                                Fee = $_.fee
                                EthStMode = 0
                                RewardType=$RewardType
                                }
                        
								#$logtext = "Ethermine " + $_.Coin + " Symbol " + $_.symbol + " Algorithm: " + $_.algo + " user: " + $CoinsWallets.get_item($_.symbol) + " Pool Workers: " + ($RequestW.data.poolStats.workers) + " Pool Hashrate: " + ($RequestW.data.poolStats.hashRate) + "Price: " + $RequestW.data.price.btc
								#$LogFile=".\Logs\ETHERMINE.txt"
								#Writelog ($logtext) $LogFile $False
                
					Remove-Variable RequestW
					Remove-Variable RequestP
			} else {
				    writelog ("No wallet for coin "+[string]$_.symbol) $logfile $false
			}
  
		}
		Remove-Variable Pools
	}
                  
$Result |ConvertTo-Json | Set-Content $info.SharedFile
Remove-Variable Result
