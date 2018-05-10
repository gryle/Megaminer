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
			"omb"{ $http="https://omb.infinity-pools.cc:8119/stats_address?address="+$Info.user}
			"msr"{ $http="https://masari.superpools.net/api/stats_address?address="+$Info.user}
			"loki"{ $http="https://loki.miner.rocks/api/stats_address?address="+$Info.user}
			"xao"{$http="https://cryptoknight.cc/rpc/alloy/stats_address?address="+$Info.user}
			"ipbc"{$http="https://support.ipbc.io/api/stats_address?address="+$Info.user}
			"rto"{ $http="http://pool.arto.cash:8117/stats_address?address="+$Info.user}
        }

        $Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 5 | ConvertFrom-Json 

        if ($Request.data -ne "") {
				$CRYPTONOTE_hashrate = [double] $Request.stats.hashrate.Split(" ")[0]
				switch ($Request.stats.hashrate.Split(" ")[1].tolower()) {
					"mh" { $CRYPTONOTE_hashrate = $CRYPTONOTE_hashrate * 1000000 }
					"kh" { $CRYPTONOTE_hashrate = $CRYPTONOTE_hashrate * 1000 }
				}
                $Result=[PSCustomObject]@{
                    PoolName =$name
                    Workername = $Info.WorkerName
                    Hashrate = $CRYPTONOTE_hashrate
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
			"loki"{ $http="https://loki.miner.rocks/api/stats_address?address="+$Info.user; $CoinUnits = 1000000000}
			"xao"{$http="https://cryptoknight.cc/rpc/alloy/stats_address?address="+$Info.user; $CoinUnits = 1000000000000}
			"ipbc"{$http="https://support.ipbc.io/api/stats_address?address="+$Info.user; $CoinUnits = 100000000}
			"rto"{ $http="http://pool.arto.cash:8117/stats_address?address="+$Info.user; $CoinUnits = 100000000}
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

        $CRYPTONOTE_Pools=@()
        $CRYPTONOTE_Pools +=[pscustomobject]@{"symbol"="OMB"; "algo"="CryptoNightHeavy";"port"=4446;"coin"="OMBRE";"location"="EU";"server"="ombre.infinity-pools.cf"}
        $CRYPTONOTE_Pools +=[pscustomobject]@{"symbol"="MSR"; "algo"="CryptoNightV7";"port"=5555;"coin"="MASARI";"location"="EU";"server"="masari.superpools.net"}
        $CRYPTONOTE_Pools +=[pscustomobject]@{"symbol"="LOKI"; "algo"="CryptoNightHeavy";"port"=5555;"coin"="LOKI";"location"="EU";"server"="loki.miner.rocks"}
        $CRYPTONOTE_Pools +=[pscustomobject]@{"symbol"="XAO"; "algo"="Alloy";"port"=5661;"coin"="ALLOY";"location"="US";"server"="alloy.ingest.cryptoknight.cc"}
        $CRYPTONOTE_Pools +=[pscustomobject]@{"symbol"="IPBC"; "algo"="IPBC";"port"=15555;"coin"="IPBC";"location"="US";"server"="support.ipbc.io"}
        $CRYPTONOTE_Pools +=[pscustomobject]@{"symbol"="RTO"; "algo"="Arto";"port"=5555;"coin"="Arto";"location"="US";"server"="pool.arto.cash"}
     
        try {
                $TRADEOGRE_Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36" "https://tradeogre.com/api/v1/markets" -UseBasicParsing -timeoutsec 10 | ConvertFrom-Json 
        }
        catch {}

        $CRYPTONOTE_Pools |  ForEach-Object {
                
		$Wallet = $CoinsWallets.get_item($_.symbol)
		if ($Wallet -ne $null -and $Wallet -ne "") {

			try {
				$CRYPTONOTE_Request=$null
				switch ($_.symbol.tolower()){
					"omb"{ $http="https://omb.infinity-pools.cc:8119/stats"; $TradeOgrePair = "BTC-OMB"}
					"msr"{ $http="https://masari.superpools.net/api/stats"; $TradeOgrePair = "BTC-MSR"}
					"loki"{ $http="https://loki.miner.rocks/api/stats"; $TradeOgrePair = "BTC-LOKI"}
					"xao"{ $http="https://cryptoknight.cc/rpc/alloy/stats";	$TradeOgrePair = "BTC-XAO"}
					"ipbc"{ $http="https://support.ipbc.io/api/stats";	$TradeOgrePair = "BTC-IPBC"}
					"rto"{ $http="http://pool.arto.cash:8117/stats";	$TradeOgrePair = "BTC-RTO"}
				}
				writelog ("Stats URL: $http") $logfile $false
				$CRYPTONOTE_Request = Invoke-WebRequest -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36"  $http -UseBasicParsing -timeoutsec 30 | ConvertFrom-Json 
			}
			catch {}
			
			$TRADEOGRE_Coin = $TRADEOGRE_Request | where-object { $_.$TradeOgrePair -ne $null } | Select-Object -ExpandProperty $TradeOgrePair
			
				$CRYPTONOTE_price = [double] $TRADEOGRE_Coin.price * 86400 / $CRYPTONOTE_Request.network.difficulty * $CRYPTONOTE_Request.network.reward / $CRYPTONOTE_Request.config.coinUnits
				writelog ("TradeOgre: $TRADEOGRE_Coin Price: $CRYPTONOTE_price") $logfile $false
			       
				$Result+=[PSCustomObject]@{
					Algorithm     = $_.algo
					Info          = $_.Coin
					Price         = $CRYPTONOTE_price
					Price24h      = $null
					Protocol      = "stratum+tcp"
					Host          = $_.server
					Port          = $_.port
					User          = $Wallet
					Pass          = $(if ($_.symbol.tolower() -eq "loki") {"w=#WorkerName#"} else {"#WorkerName#"})
					Location      = $_.location
					SSL           = $false
					Symbol        = $_.symbol
					AbbName       = $AbbName
					ActiveOnManualMode    = $ActiveOnManualMode
					ActiveOnAutomaticMode = $ActiveOnAutomaticMode
					PoolWorkers   = $CRYPTONOTE_Request.pool.miners
					PoolHashRate  = $CRYPTONOTE_Request.pool.hashrate
					Blocks_24h    = $null
					WalletMode    = $WalletMode
					WalletSymbol    = $_.symbol
					PoolName = $Name
					Fee = [double] $CRYPTONOTE_Request.config.fee / 100
					EthStMode = 0
					RewardType=$RewardType
				}
				Remove-Variable CRYPTONOTE_Request
			
		} else {
		    writelog ("No wallet for coin "+[string]$_.symbol) $logfile $false
		}
  
	}
Remove-Variable TRADEOGRE_Request
Remove-Variable CRYPTONOTE_Pools
}
                  
$Result |ConvertTo-Json | Set-Content $info.SharedFile
Remove-Variable Result
