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
$AbbName = 'CNOTE'
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
            "sumo"{$http="https://sumokoin.hashvault.pro/api/miner/"+$Info.user+"/stats"}
            "itns"{$http="https://intense.hashvault.pro/api/miner/"+$Info.user+"/stats"}
        }

        $Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 5 | ConvertFrom-Json 

        if ($Request.data -ne "") {
                $CRYPTOKNIGHT_hashrate = [double] $Request.hash
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
			"sumo"{$coinUnits=1000000000; $http="https://sumokoin.hashvault.pro/api/miner/"+$Info.user+"/stats"}
			"itns"{$coinUnits=1000000000; $http="https://intense.hashvault.pro/api/miner/"+$Info.user+"/stats"}
		}
	    $Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 5 | ConvertFrom-Json 
	}
	catch {}


	$Result=[PSCustomObject]@{
				Pool =$name
				currency = $Info.OriginalCoin                                                                                                           
				balance = $Request.amtDue / $coinUnits
	}
}

                        

#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************


if (($Querymode -eq "core" ) -or ($Querymode -eq "Menu")){

        $CRYPTOKNIGHT_Pools=@()
        $CRYPTOKNIGHT_Pools +=[pscustomobject]@{"symbol"="SUMO"; "algo"="CryptoNightHeavy";"port"=5555;"coin"="SUMOKOIN";"location"="EU";"server"="pool.sumokoin.hashvault.pro"}
        $CRYPTOKNIGHT_Pools +=[pscustomobject]@{"symbol"="ITNS"; "algo"="CryptoNightV7";"port"=5555;"coin"="INTENSECOIN";"location"="EU";"server"="pool.intense.hashvault.pro"}

     
        try {
                $TRADEOGRE_Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36" "https://tradeogre.com/api/v1/markets" -UseBasicParsing -timeoutsec 10 | ConvertFrom-Json 
        }
        catch {}

        $CRYPTOKNIGHT_Pools |  ForEach-Object {
                
		$Wallet = $CoinsWallets.get_item($_.symbol)
		if ($Wallet -ne $null -and $Wallet -ne "") {

			try {
				$CRYPTOKNIGHT_Request=$null
				switch ($_.symbol.tolower()){
					"sumo"{ $http="https://sumokoin.hashvault.pro/api"; $CoinUnits = 1000000000; $TradeOgrePair = "BTC-SUMO"}
					"itns"{ $http="https://intense.hashvault.pro/api"; $CoinUnits = 1000000000; $TradeOgrePair = "BTC-ITNS"}
				}
				writelog ("Stats URL: $http") $logfile $false
				$CRYPTOKNIGHT_Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http + "/network/stats" -UseBasicParsing -timeoutsec 10 | ConvertFrom-Json 
				Start-Sleep 1
				$CRYPTOKNIGHT_Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http + "/pool/stats" -UseBasicParsing -timeoutsec 10 | ConvertFrom-Json 
			}
			catch {}
			
			$TRADEOGRE_Coin = $TRADEOGRE_Request | where-object { $_.$TradeOgrePair -ne $null } | Select-Object -ExpandProperty $TradeOgrePair
			$CRYPTOKNIGHT_price = [double] $TRADEOGRE_Coin.price * 86400 / $CRYPTOKNIGHT_Request.difficulty * $CRYPTOKNIGHT_Request.value / $CoinUnits
			
			writelog ("TradeOgre: $TRADEOGRE_Coin Price: $CRYPTOKNIGHT_price") $logfile $false
		       
			$Result+=[PSCustomObject]@{
				Algorithm     = $_.algo
				Info          = $_.Coin
				Price         = $CRYPTOKNIGHT_price
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
				PoolWorkers   = $CRYPTOKNIGHT_Request2.pool_statistics.miners
				PoolHashRate  = $CRYPTOKNIGHT_Request2.pool_statistics.hashRate
				Blocks_24h    = $null
				WalletMode    = $WalletMode
				WalletSymbol    = $_.symbol
				PoolName = $Name
				Fee = [double] $CRYPTOKNIGHT_Request2.pool_statistics.fee / 100
				EthStMode = 0
				RewardType=$RewardType
			}
			
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
