gofer {
  price_model "BTC/USD" "median" {
    source "BTC/USD" "origin" { origin = "bitfinex" }
    source "BTC/USD" "origin" { origin = "coinbasepro" }
    source "BTC/USD" "origin" { origin = "kraken" }
    min_sources = 1
  }
  price_model "ETH/GSU" "median" {
    source "ETH/GSU" "origin" { origin = "GSU" }
    min_sources = 1
  }
}
