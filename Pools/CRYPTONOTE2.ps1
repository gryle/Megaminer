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
$AbbName = 'CNOT2'
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
			"omb"{ $http="https://omb.infinity-pools.cc:8119/stats_address?address="+$Info.user; $CoinUnits = 1000000000}
			"msr"{ $http="https://masari.superpools.net/api/stats_address?address="+$Info.user; $CoinUnits = 1000000000000}
        }

        $Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 5 | ConvertFrom-Json 

        if ($Request.data -ne "") {
				$CRYPTONOTE2_hashrate = [double] $Request.stats.hashrate.Split(" ")[0]
				switch ($Request.stats.hashrate.Split(" ")[1].tolower()) {
					"mh" { $CRYPTONOTE2_hashrate = $CRYPTONOTE2_hashrate * 1000000 }
					"kh" { $CRYPTONOTE2_hashrate = $CRYPTONOTE2_hashrate * 1000 }
				}
                $Result=[PSCustomObject]@{
                    PoolName =$name
                    Workername = $Info.WorkerName
                    Hashrate = $CRYPTONOTE2_hashrate
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
			"omb"{ $http="https://omb.infinity-pools.cc:8119/stats_address?address="+$Info.user; $CoinUnits = 1000000000}
			"msr"{ $http="https://masari.superpools.net/api/stats_address?address="+$Info.user; $CoinUnits = 1000000000000}
		}
	    $Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 5 | ConvertFrom-Json 
	}
	catch {}


	$Result=[PSCustomObject]@{
				Pool =$name
				currency = $Info.OriginalCoin                                                                                                           
				balance = $Request.stats.balance / $CoinUnits
	}
}

                        

#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************


if (($Querymode -eq "core" ) -or ($Querymode -eq "Menu")){

        $CRYPTONOTE2_Pools=@()
        $CRYPTONOTE2_Pools +=[pscustomobject]@{"symbol"="OMB"; "algo"="CryptoNightHeavy";"port"=4446;"coin"="OMBRE";"location"="EU";"server"="ombre.infinity-pools.cf"}
        $CRYPTONOTE2_Pools +=[pscustomobject]@{"symbol"="MSR"; "algo"="CryptoNightV7";"port"=5555;"coin"="MASARI";"location"="EU";"server"="masari.superpools.net"}

     
        try {
                $TRADEOGRE_Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36" "https://tradeogre.com/api/v1/markets" -UseBasicParsing -timeoutsec 10 | ConvertFrom-Json 
        }
        catch {}

        $CRYPTONOTE2_Pools |  ForEach-Object {
                
		$Wallet = $CoinsWallets.get_item($_.symbol)
		if ($Wallet -ne $null -and $Wallet -ne "") {

			try {
				$CRYPTONOTE2_Request=$null
				switch ($_.symbol.tolower()){
					"omb"{ $http="https://omb.infinity-pools.cc:8119/stats"; $CoinUnits = 1000000000; $TradeOgrePair = "BTC-OMB"}
					"msr"{ $http="https://masari.superpools.net/api/stats"; $CoinUnits = 1000000000000; $TradeOgrePair = "BTC-MSR"}
				}
				writelog ("Stats URL: $http") $logfile $false
				$CRYPTONOTE2_Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 30 | ConvertFrom-Json 
			}
			catch {}
			
			$TRADEOGRE_Coin = $TRADEOGRE_Request | where-object { $_.$TradeOgrePair -ne $null } | Select-Object -ExpandProperty $TradeOgrePair
			
				$CRYPTONOTE2_price = [double] $TRADEOGRE_Coin.price * 86400 / $CRYPTONOTE2_Request.network.difficulty * $CRYPTONOTE2_Request.network.reward / $CoinUnits
				
				writelog ("TradeOgre: $TRADEOGRE_Coin Price: $CRYPTONOTE2_price") $logfile $false
			       
				$Result+=[PSCustomObject]@{
					Algorithm     = $_.algo
					Info          = $_.Coin
					Price         = $CRYPTONOTE2_price
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
					PoolWorkers   = $CRYPTONOTE2_Request.pool.miners
					PoolHashRate  = $CRYPTONOTE2_Request.pool.hashrate
					Blocks_24h    = $null
					WalletMode    = $WalletMode
					WalletSymbol    = $_.symbol
					PoolName = $Name
					Fee = [double] $CRYPTONOTE2_Request.config.fee / 100
					EthStMode = 0
					RewardType=$RewardType
				}
				Remove-Variable CRYPTONOTE_Request
			
		} else {
		    writelog ("No wallet for coin "+[string]$_.symbol) $logfile $false
		}
  
	}
Remove-Variable CRYPTONOTE_Pools
}
                  
$Result |ConvertTo-Json | Set-Content $info.SharedFile
Remove-Variable Result
