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
$AbbName = 'CRKN'
$WalletMode="WALLET"
$Result=@()
$RewardType='PPS'

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
            "xhv"{$http="https://cryptoknight.cc/rpc/haven/stats_address?address="+$Info.user}
            "xtl"{$http="https://cryptoknight.cc/rpc/stellite/stats_address?address="+$Info.user}
            "ipbc"{$http="https://cryptoknight.cc/rpc/ipbc/stats_address?address="+$Info.user}
            "grft"{$http="https://cryptoknight.cc/rpc/graft/stats_address?address="+$Info.user}
            "xao"{$http="https://cryptoknight.cc/rpc/alloy/stats_address?address="+$Info.user}
        }

        $Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 5 | ConvertFrom-Json 

        if ($Request.data -ne "") {
				$CRYPTOKNIGHT_hashrate = [double] $Request.stats.hashrate.Split(" ")[0]
				switch ($Request.stats.hashrate.Split(" ")[1].tolower()) {
					"mh" { $CRYPTOKNIGHT_hashrate = $CRYPTOKNIGHT_hashrate * 1000000 }
					"kh" { $CRYPTOKNIGHT_hashrate = $CRYPTOKNIGHT_hashrate * 1000 }
				}
                $Result=[PSCustomObject]@{
                    PoolName =$name
                    Workername = $Info.WorkerName
                    Hashrate = $CRYPTOKNIGHT_hashrate
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
										"xhv"{$http="https://cryptoknight.cc/rpc/haven/stats_address?address="+$Info.user}
										"xtl"{$http="https://cryptoknight.cc/rpc/stellite/stats_address?address="+$Info.user}
										"ipbc"{$http="https://cryptoknight.cc/rpc/ipbc/stats_address?address="+$Info.user}
										"grft"{$http="https://cryptoknight.cc/rpc/graft/stats_address?address="+$Info.user}
										"xao"{$http="https://cryptoknight.cc/rpc/alloy/stats_address?address="+$Info.user}										
									}
                                    $Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 5 | ConvertFrom-Json 
                                }
                                catch {}

                        
                                $Result=[PSCustomObject]@{
                                                        Pool =$name
                                                        currency = $Info.OriginalCoin														
                                                        balance = $Request.stats.balance
                                                    }
                        }

                        

#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************


if (($Querymode -eq "core" ) -or ($Querymode -eq "Menu")){

        $CRYPTOKNIGHT_Pools=@()
        $CRYPTOKNIGHT_Pools +=[pscustomobject]@{"symbol"="XHV"; "algo"="CryptoNightHeavy";"port"=5531;"coin"="HAVEN";"location"="US";"server"="haven.ingest.cryptoknight.cc"; "fee"=0.0}
        $CRYPTOKNIGHT_Pools +=[pscustomobject]@{"symbol"="XTL"; "algo"="cryptonightv7";"port"=16221;"coin"="STELLITE";"location"="US";"server"="stellite.ingest.cryptoknight.cc"; "fee"=0.0}
        #$CRYPTOKNIGHT_Pools +=[pscustomobject]@{"symbol"="IPBC"; "algo"="IPBC";"port"=4461;"coin"="IPBC";"location"="US";"server"="ipbc.ingest.cryptoknight.cc"; "fee"=0.0}
        $CRYPTOKNIGHT_Pools +=[pscustomobject]@{"symbol"="GRFT"; "algo"="cryptonightv7";"port"=9111;"coin"="GRAFT";"location"="US";"server"="graft.ingest.cryptoknight.cc"; "fee"=0.0}
        #$CRYPTOKNIGHT_Pools +=[pscustomobject]@{"symbol"="XAO"; "algo"="Alloy";"port"=5661;"coin"="ALLOY";"location"="US";"server"="alloy.ingest.cryptoknight.cc"; "fee"=0.0}

     


        $CRYPTOKNIGHT_Pools |  ForEach-Object {
		
			$Wallet = $CoinsWallets.get_item($_.symbol)
			if ($Wallet -ne $null -and $Wallet -ne "") {

                try {
                    $CRYPTOKNIGHT_Request=$null
					switch ($_.symbol.tolower()){
						"xhv"{ $http="https://cryptoknight.cc/rpc/haven/stats";	$Divisor = 1000}
						"xtl"{ $http="https://cryptoknight.cc/rpc/stellite/stats"; $Divisor = 1000}
						"ipbc"{ $http="https://cryptoknight.cc/rpc/ipbc/stats"; $Divisor = 1000}
						"grft"{ $http="https://cryptoknight.cc/rpc/graft/stats"; $Divisor = 1000}
						"xao"{ $http="https://cryptoknight.cc/rpc/alloy/stats";	$Divisor = 1000}
					}
					writelog ("Stats URL: $http") $logfile $false
                    $CRYPTOKNIGHT_Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 10 | ConvertFrom-Json 
					Start-Sleep 1
					# $BTCPriceResponse = Invoke-WebRequest "https://api.coindesk.com/v1/bpi/currentprice.json" -UseBasicParsing -TimeoutSec 2 | ConvertFrom-Json | Select-Object -ExpandProperty BPI
					# $USDBTCvalue = [double]$BTCPriceResponse.usd.rate
					# writelog ("USDBTCvalue: $USDBTCvalue") $logfile $false
                }
                catch {}

					$CRYPTOKNIGHT_priceUSD = [double] $CRYPTOKNIGHT_Request.charts.priceUSD[-1][1]
					$CRYPTOKNIGHT_price = [double] $CRYPTOKNIGHT_Request.charts.price[-1][1]
					$CRYPTOKNIGHT_profit = [double] $CRYPTOKNIGHT_Request.charts.profit3[-1][1]
					$CRYPTOKNIGHT_profitBTC = $CRYPTOKNIGHT_profit / $CRYPTOKNIGHT_priceUSD * $CRYPTOKNIGHT_price / 100000000
					writelog ("Profit: $CRYPTOKNIGHT_profit Price Sat: $CRYPTOKNIGHT_price Price USD: $CRYPTOKNIGHT_priceUSD ProfitBTC: $CRYPTOKNIGHT_profitBTC") $logfile $false
               
                    $Result+=[PSCustomObject]@{
                                Algorithm     = $_.algo
                                Info          = $_.Coin
                                Price         = ($CRYPTOKNIGHT_profitBTC / $Divisor)
                                Price24h      = $null
                                Protocol      = "stratum+tcp"
                                Host          = $_.server
                                Port          = $_.port
                                User          = $Wallet
                                Pass          = "#WorkerName#"
                                Location      = $_.location
                                SSL           = $false
                                Symbol        = $_.symbol
                                AbbName       = $AbbName
                                ActiveOnManualMode    = $ActiveOnManualMode
                                ActiveOnAutomaticMode = $ActiveOnAutomaticMode
                                PoolWorkers   = $CRYPTOKNIGHT_Request.pool.miners
                                PoolHashRate  = $CRYPTOKNIGHT_Request.pool.hashRate
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
                
					Remove-Variable CRYPTOKNIGHT_Request
					#Remove-Variable BTCPriceResponse
			} else {
				    writelog ("No wallet for coin "+[string]$_.symbol) $logfile $false
			}
  
		}
		Remove-Variable CRYPTOKNIGHT_Pools
	}
                  
$Result |ConvertTo-Json | Set-Content $info.SharedFile
Remove-Variable Result
