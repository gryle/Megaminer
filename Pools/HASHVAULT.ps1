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
$AbbName = 'HVAULT'
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
		$http = $null
        switch ($Info.symbol.tolower()){
            "ryo"{$http="https://ryo.hashvault.pro/api/miner/"+$Info.user+"/stats"}
            "itns"{$http="https://intense.hashvault.pro/api/miner/"+$Info.user+"/stats"}
            "aeon"{$http="https://aeon.hashvault.pro/api/miner/"+$Info.user+"/stats"}
        }

        if ($http -ne $null) { $Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 5 | ConvertFrom-Json  }

		$HASHVAULT_hashrate = [double] $Request.hash
		$Result=[PSCustomObject]@{
			PoolName =$name
			Workername = $Info.WorkerName
			Hashrate = $HASHVAULT_hashrate
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
		$http = $null
		$coinUnits = 1
		switch ($Info.symbol.tolower()){
			"ryo"{$coinUnits=1000000000; $http="https://ryo.hashvault.pro/api/miner/"+$Info.user+"/stats"}
			"itns"{$coinUnits=100000000; $http="https://intense.hashvault.pro/api/miner/"+$Info.user+"/stats"}
			"aeon"{$coinUnits=1000000000000; $http="https://aeon.hashvault.pro/api/miner/"+$Info.user+"/stats"}
		}
		if ($http -ne $null) { $Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 5 | ConvertFrom-Json  }
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

        $HASHVAULT_Pools=@()
        $HASHVAULT_Pools +=[pscustomobject]@{"symbol"="RYO"; "algo"="CryptoNightHeavy";"port"=5555;"coin"="RYO";"location"="EU";"server"="pool.ryo.hashvault.pro"}
        $HASHVAULT_Pools +=[pscustomobject]@{"symbol"="ITNS"; "algo"="CryptoNightV7";"port"=5555;"coin"="INTENSECOIN";"location"="EU";"server"="pool.intense.hashvault.pro"}
        $HASHVAULT_Pools +=[pscustomobject]@{"symbol"="AEON"; "algo"="CryptoLightV7";"port"=5555;"coin"="AEON";"location"="EU";"server"="pool.aeon.hashvault.pro"}

     
        try {
                $TRADEOGRE_Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36" "https://tradeogre.com/api/v1/markets" -UseBasicParsing -timeoutsec 10 | ConvertFrom-Json 
        }
        catch {}

        $HASHVAULT_Pools |  ForEach-Object {
                
		$Wallet = $CoinsWallets.get_item($_.symbol)
		if ($Wallet -ne $null -and $Wallet -ne "") {

			try {
				$HASHVAULT_Request=$null
				switch ($_.symbol.tolower()){
					"ryo"{ $http="https://ryo.hashvault.pro/api"; $CoinUnits = 1000000000; $TradeOgrePair = "BTC-RYO"}
					"itns"{ $http="https://intense.hashvault.pro/api"; $CoinUnits = 100000000; $TradeOgrePair = "BTC-ITNS"}
					"aeon"{ $http="https://aeon.hashvault.pro/api"; $CoinUnits = 1000000000000; $TradeOgrePair = "BTC-AEON"}
				}
				writelog ("Stats URL: $http") $logfile $false
				$HASHVAULT_Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  "$http/network/stats" -UseBasicParsing -timeoutsec 10 | ConvertFrom-Json 
				Start-Sleep 1
				$HASHVAULT_Request2 = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  "$http/pool/stats" -UseBasicParsing -timeoutsec 10 | ConvertFrom-Json 
			}
			catch {}
			
			$TRADEOGRE_Coin = $TRADEOGRE_Request | where-object { $_.$TradeOgrePair -ne $null } | Select-Object -ExpandProperty $TradeOgrePair
			
			$HASHVAULT_price = [double] $TRADEOGRE_Coin.bid * 86400 / $HASHVAULT_Request.difficulty * $HASHVAULT_Request.value / $CoinUnits
			
			writelog ("TradeOgre: $TRADEOGRE_Coin Price: $HASHVAULT_price") $logfile $false
			   
			$Result+=[PSCustomObject]@{
				Algorithm     = $_.algo
				Info          = $_.Coin
				Price         = $HASHVAULT_price
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
				PoolWorkers   = $HASHVAULT_Request2.pool_statistics.miners
				PoolHashRate  = $HASHVAULT_Request2.pool_statistics.hashRate
				Blocks_24h    = $null
				WalletMode    = $WalletMode
				WalletSymbol    = $_.symbol
				PoolName = $Name
				Fee = [double] $HASHVAULT_Request2.pool_statistics.fee / 100
				EthStMode = 0
				RewardType=$RewardType
			}
			Remove-Variable HASHVAULT_Request
			Remove-Variable HASHVAULT_Request2

		} else {
		    writelog ("No wallet for coin "+[string]$_.symbol) $logfile $false
		}
	}
Remove-Variable TRADEOGRE_Request
Remove-Variable HASHVAULT_Pools
}
                  
$Result |ConvertTo-Json | Set-Content $info.SharedFile
Remove-Variable Result
