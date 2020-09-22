class API < Sinatra::Base
  def intialize(ledger: Ledger.new)
    @ledger = ledger
    super() 
  end
end