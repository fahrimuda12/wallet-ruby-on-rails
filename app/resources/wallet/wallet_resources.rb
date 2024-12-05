module WalletResources
    class WalletMutation
        def initialize(wallets)
            @wallets = wallets
        end

        # transform data wallet
        def transform
            return @wallets.map do |wallet|
                  {
                    id: wallet.id,
                    name: wallet.name,
                    created_at: wallet.created_at,
                    updated_at: wallet.updated_at
                  }
        end
    end
end