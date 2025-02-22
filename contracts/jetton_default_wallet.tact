import "@stdlib/ownable";
import "./messages";

// ============================================================ //
@interface("org.ton.jetton.wallet")
contract JettonDefaultWallet {
    const minTonsForStorage: Int = ton("0.019");
    const gasConsumption: Int = ton("0.013");

    balance: Int as coins = 0;
    owner: Address;
    master: Address;

    init(owner: Address, master: Address) {
        self.balance = 0;
        self.owner = owner;
        self.master = master;
    }

    receive(msg: TokenTransfer) { // 0xf8a7ea5
        // TODO tests
        // let ctx: Context = context(); // Check sender
        // // TODO tests
        // // require(ctx.sender == self.owner, "Invalid sender");

        // let final: Int = ctx.readForwardFee() * 2 + 
        //                     2 * self.gasConsumption + 
        //                         self.minTonsForStorage + 
        //                             msg.forward_ton_amount;   // Gas checks, forward_ton = 0.152
        // require(ctx.value > final, "Invalid value"); 

        // Update balance
        self.balance = self.balance - msg.amount; 
        // TODO tests
        // require(self.balance >= 0, "Invalid balance");

        let init: StateInit = initOf JettonDefaultWallet(msg.sender, self.master);  
        let wallet_address: Address = contractAddress(init);
        send(SendParameters{
            to: wallet_address, 
            value: 0,
            mode: SendRemainingValue, 
            bounce: false,
            body: TokenTransferInternal{ // 0x178d4519
                query_id: msg.query_id,
                amount: msg.amount,
                from: self.owner,
                response_destination: msg.response_destination,
                forward_ton_amount: msg.forward_ton_amount,
                forward_payload:  msg.forward_payload
            }.toCell(),
            code: init.code,
            data: init.data
        });
    }

    receive(msg: TokenTransferInternal) { // 0x178d4519
        // TODO tests
        // let ctx: Context = context();
        // if (ctx.sender != self.master) {
        //     let sinit: StateInit = initOf JettonDefaultWallet(msg.from, self.master);
        //     require(contractAddress(sinit) == ctx.sender, "Invalid sender!");
        // }

        // TODO tests
        // Update balance
        self.balance = self.balance + msg.amount;
        // require(self.balance >= 0, "Invalid balance"); 
        
        // TODO tests
        // Get value for gas
        // let msg_value: Int = self.msg_value(ctx.value);  
        // let fwd_fee: Int = ctx.readForwardFee();
        // if (msg.forward_ton_amount > 0) { 
        //         msg_value = msg_value - msg.forward_ton_amount - fwd_fee;
        //         send(SendParameters{
        //             to: self.owner,
        //             value: msg.forward_ton_amount,
        //             mode: SendPayGasSeparately,
        //             bounce: false,
        //             body: TokenNotification { // 0x7362d09c -- Remind the new Owner
        //                 query_id: msg.query_id,
        //                 amount: msg.amount,
        //                 from: msg.from,
        //                 forward_payload: msg.forward_payload
        //             }.toCell()
        //         });
        // }

        // TODO tests
        // 0xd53276db -- Cashback to the original Sender
        // if (msg.response_destination != null && msg_value > 0) { 
        //     send(SendParameters {
        //         to: msg.response_destination!!, 
        //         value: msg_value,  
        //         bounce: false,
        //         body: TokenExcesses { query_id: msg.query_id }.toCell(),
        //         mode: SendPayGasSeparately
        //     });
        // }
    }

    receive(msg: TokenBurn) {
        // TODO tests
        // let ctx: Context = context();
        // require(ctx.sender == self.owner, "Invalid sender");  // Check sender

        self.balance = self.balance - msg.amount; // Update balance
        // TODO tests
        // require(self.balance >= 0, "Invalid balance");

        // let fwd_fee: Int = ctx.readForwardFee(); // Gas checks
        // require(ctx.value > fwd_fee + 2 * self.gasConsumption + self.minTonsForStorage, "Invalid value - Burn");

        // Burn tokens
        // send(SendParameters{  
        //     to: self.master,
        //     value: 0,
        //     mode: SendRemainingValue,
        //     bounce: true,
        //     body: TokenBurnNotification{
        //         query_id: msg.query_id,
        //         amount: msg.amount,
        //         sender: self.owner,
        //         response_destination: msg.response_destination!!
        //     }.toCell()
        // });
    }


    fun msg_value(value: Int): Int {
        let msg_value: Int = value;
        let ton_balance_before_msg: Int = myBalance() - msg_value;
        let storage_fee: Int = self.minTonsForStorage - min(ton_balance_before_msg, self.minTonsForStorage);
        msg_value = msg_value - (storage_fee + self.gasConsumption);
        return msg_value;
    }

    bounced(msg: bounced<TokenTransferInternal>) {
        // TODO tests
        // self.balance = self.balance + msg.amount;
    }

    bounced(msg: bounced<TokenBurnNotification>) {
        // TODO tests
        // self.balance = self.balance + msg.amount;
    }

    get fun get_wallet_data(): JettonWalletData {
        return JettonWalletData{
            balance: self.balance,
            owner: self.owner,
            master: self.master,
            code: (initOf JettonDefaultWallet(self.owner, self.master)).code
        };
    }
}