// SPDX-License-Identifier: null
pragma solidity ^0.6.7;
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract HW2Token is Context, IERC20{
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    
    address _owner;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_)public {
        _name = name_;
        _symbol = symbol_;
        _owner = msg.sender;
    }
    
    function mint(address to, uint256 amount) public{
        require(_owner == msg.sender);
        _mint(to,amount);
    }
    
    function burn(address to, uint256 amount) public{
        require(_owner == msg.sender);
        _burn(to,amount);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual  returns (uint8) {
        return 0;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        
        _transfer(sender, recipient, amount);

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_totalSupply == 0, "Tokens can be minted only once.");
        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

contract DAO{
    /**  
    *    @dev Dao stands for Decentralised Autonomus Organization,
    *    The primary objective of this contract is for token holders
    *    to gain access to a voting proccess, the token holders will
    *    also receive an amount of money for holding the tokens,
    *    like a "divident", the token holders can vote a token if they
    *    own %2 of the votes, their proposal will pass only if %20
    *    of all tokens are voted on the token of their choice.
    *
    */
    HW2Token public votingToken = HW2Token(address(0x9669c26242ef4054DEE436215C271507204998d9));
    //setting the votingToken as our newly created token...
    
    mapping(address => uint256)public votes;
    mapping(address => uint256) usedVotes;
    address[] public voters;
    mapping(address => uint256) rewards;
    mapping(address=>mapping(address=> uint256)) userRewards;
    address[] public approvedTokens;
    uint256 totalVotes = votingToken.totalSupply();
    struct tokenToVoteOn{
        address tokenAddress;
        uint256 votes;
        uint256 time;
    }
    uint256 lastDivident = 0;
    
    function receiveRewards(uint256 amount, address tokenAddress) public payable{
        require(HW2Token(tokenAddress).transferFrom(msg.sender,address(this),amount));
        rewards[tokenAddress] += amount;
    }
   
   function divident(address tokenAddress, address Exchange) private{
        //every once in a while, the DAO will give tokens to its token holders who participate in voting,
        //this is for encouraging voting among token holders.
        decentralisedExchange(Exchange).sendRewards(tokenAddress);
        HW2Token(tokenAddress).approve(address(this),rewards[tokenAddress]);
        for(uint256 i = 0; i < voters.length; i++){
            userRewards[voters[i]][tokenAddress] += (rewards[tokenAddress] *((votes[voters[i]] + usedVotes[voters[i]] )/ totalVotes));
        }
    }
    function withdrawDivident(address tokenAddress) public{
        HW2Token(tokenAddress).transferFrom(address(this),msg.sender,userRewards[msg.sender][tokenAddress]);
    }
    
    function UserDividentFunction(address Exchange) public{
        
        require(block.timestamp > (lastDivident + 100)); // yearly automated dividents to our token holders. currently 100 seconds for debugging.
        lastDivident = block.timestamp;
        for(uint256 i = 0; i < approvedTokens.length; i++){
            divident(approvedTokens[i],Exchange);
        }
    }
   
   
    tokenToVoteOn public tokenToAdd;
    
    
    /**  
    *    @dev checkVoters function checks if the sender is 
    *    in the voters array or not, if it is not in the 
    *    array, it adds it to the array.
    *    
    *
    */
    
    function checkVoters(address voter) private view returns(bool){
        for (uint256 i= 0; i < voters.length; i++){
            if(voters[i] == voter){
                return false;
            }
        }
        
        return true;
    }
    
     /**  
    *    
    *    @dev returns approved tokens, 
    *    this is primarily used in the exchange contract,
    *    for adding the newest approved tokens to it.
    *
    */
    
    function returnApprovedTokens() public view returns(address[] memory){
        return approvedTokens;
    }
    
     /**  
    *    @dev _depositVotes is for a user to be able to vote for a token,
    *    the deposited votes can be withdrawn at any point in the voting
    *    proccess.
    *    
    *
    */
    
    
    function _depositVotes(uint256 amount) public payable{
        require(votingToken.transferFrom(msg.sender,address(this),amount), "you need to approve enough tokens for transfer to this contracts address");
        votes[msg.sender] += amount; // uninitialised uint256 is 0 in mappings, we will use it to our advantage.
        if(checkVoters(msg.sender)){
            voters.push(msg.sender);
        }
    }
    
     /**  
    *    
    *    @dev withdraw voting tokens from this contract.
    *   
    *    
    *
    */
    
    function _withdrawVotes(uint256 amount) public{
        require (votes[msg.sender] >= amount , "You have not deposited this many tokens to our DAO");
        votes[msg.sender] -= amount;
        votingToken.approve(address(this), amount);
        votingToken.transferFrom(address(this),msg.sender, amount);
    }
    
     /**  
    *    @dev _startVotingProccess starts a vote for the desired token,
    *    it checks if the user has at least %2 of the tokens, if they do not,
    *    the function reverts.
    *    
    *
    */
    
    function _startVotingProccess(address tokenAddress) public{
        require(votes[msg.sender] >= (totalVotes / 50), "you must own at least 2% of the votes to start a voting proccess");
        require(tokenToAdd.tokenAddress == address(0x0), "a token is currently being voted on, try again later.");
        tokenToAdd.votes = 0;
        tokenToAdd.tokenAddress = tokenAddress;
        tokenToAdd.time = block.timestamp + 20; //current block timestamp as seconds since unix epoch + 1 day
    }
    
     /**  
    *    @dev _voteOnToken is for voting on the current token,
    *    the tokens are transferred from the users votes[] array 
    *    to their usedVotes[] array, this is to stop people from 
    *    trying to withdraw votes after they vote for a token.
    *
    */
    
    function _voteOnToken(uint256 amount) public{
        require(votes[msg.sender] >= amount, "not enough votes !");
        votes[msg.sender] -= amount;
        usedVotes[msg.sender] += amount;
        tokenToAdd.votes += amount;
    }
    
     /**  
    *   @dev _withdrawVotesFromToken is for a user who wants to withdraw   
    *    their tokens from the voting proccess, after they withdraw from
    *    the proccess, they can withdraw their tokens for real,
    *    by calling the withdraw function.
    *
    */
    
    
    function _withdrawVotesFromToken(uint256 amount) public{
        require(usedVotes[msg.sender] >= amount, "you have not voted this much tokens on the proposal.");
        usedVotes[msg.sender] -= amount;
        tokenToAdd.votes -= amount;
        votes[msg.sender] += amount;
    }
    
     /** 
    *    @dev If a vote has less than %2 total amount of votes
    *    it can be revoked, this function revokes the voting
    *    proccess and makes the _startVotingProccess to be
    *    usefull again.
    *
    */
    
    function _revokeVoting() public{
        require(tokenToAdd.tokenAddress != address(0x0));
        require(tokenToAdd.votes < totalVotes / 50, "you may not revoke voting if the token has at least %2 of total votes.");
        tokenToAdd.tokenAddress = address(0x0);
        for(uint256 i = 0;i < voters.length ;i ++ ){
            votes[voters[i]] += usedVotes[voters[i]];
            usedVotes[voters[i]] = 0;
        }
    }
    
     /**
    *    @dev This function ends the vote,
    *    it checks if the time limit has been reached,
    *    and if %20 of total votes have been voted on 
    *    this token address, the token is added to the approvedTokens[]
    *    array.
    */
    
    function _endVoting() public{
        require(tokenToAdd.tokenAddress != address(0x0));
        require(block.timestamp >= tokenToAdd.time, "the voting has not yet ended !");
        if(tokenToAdd.votes > (totalVotes / 5)){
            approvedTokens.push(tokenToAdd.tokenAddress); // token has been added to approved tokens...
        }
        tokenToAdd.tokenAddress = address(0x0);
        for(uint256 i = 0;i < voters.length ;i ++ ){
            votes[voters[i]] += usedVotes[voters[i]];
            usedVotes[voters[i]] = 0;
        }
        
        
    }
    
}

contract decentralisedExchange{
    
     /** 
    *    @dev This is the DEX, this is a simple dex,
    *    which uses chainlink for oracle services, 
    *    it rewards the market makers based on their contrubution
    *    and their patience. The market makers rewards increase the
    *    more time they leave their tokens on this exchange.
    */
    
    mapping(address => bool) approvedTokens;
    address public DAOaddress;
    mapping (address => uint256) totalTokens;
    struct MM{
        mapping(address => uint256) balances;
        address[] tokenAddreses;
        bool created;
    }
    mapping(address => uint256) swapRewards;
    mapping(address => uint256) daoSwapRewards;
    //time spent will work in this way..
        // the market maker will deposit tokens to the exchange,
        // after leaving the tokens for a "desired" amount of time, the maker's reward will increase
        // this is for encouraging the market makers to deposit money,
        // the reward increase will be proportional to the tokens they have deposited to the exchange.
    
    mapping (address => MM) private marketMakers;
    address[] private marketMakerAddresses;
    constructor (address decentralisedAutonomusOrganizationAddress) public{
        DAOaddress = decentralisedAutonomusOrganizationAddress;
        
    }
    
     modifier onlyDao{
        require(msg.sender == DAOaddress);
        _;
    }
    
    
     /** 
    *    @dev getApprovedTokens function gets approved tokens 
    *    from the DAO contract and assigns them as swappable tokens.
    *    no other token can be swapped except for the approvedTokens
    *    
    *
    */
    function getApprovedTokens() public{
        DAO theDAO = DAO(DAOaddress);
        for(uint256 i= 0; i < theDAO.returnApprovedTokens().length; i++){
            
            approvedTokens[theDAO.returnApprovedTokens()[i]] = true;
            
        }
    }
    /**  
    *    @dev _marketMakerDeposit is for market makers to deposit
    *    their tokens to the market, they receive a reward for each
    *    exchange that happens on this market, the token holders also
    *    get a payment for each transaction after a decided upon time
    *    by the DAO.
    */
    
    function _marketMakerDeposit(address tokenAddress, uint256 amount) public payable{
        HW2Token Token = HW2Token(tokenAddress);
        require(approvedTokens[tokenAddress] == true, "this token is not approved for our exchange, go to the DAO contract and try to approve it from there, if you already did this, please call getApprovedTokens function.");
        require(Token.transferFrom(msg.sender,address(this), amount), "approve tokens for this contracts address, after that give the right amount of tokens you wish to transfer.");
        totalTokens[tokenAddress] += amount;
        marketMakers[msg.sender].balances[tokenAddress] += amount;
        if(marketMakers[msg.sender].created == false){
            
            marketMakers[msg.sender].created = true;
            marketMakerAddresses.push(msg.sender);
            
        }
        
    }
     /**  
    *       @dev _marketMakerWithdraw is for withdrawing tokens   
    *       that have been sent to the exchange by the marketMakers
    *       
    *    
    *
    */
    function _marketMakerWithdraw(address tokenAddress, uint256 amount) public{
        HW2Token Token = HW2Token(tokenAddress);
        require(approvedTokens[tokenAddress] == true, "this token is not approved for our exchange, go to the DAO contract and try to approve it from there, if you already did this, please call getApprovedTokens function.");
        require(marketMakers[msg.sender].balances[tokenAddress] >= amount, "you do not have this many tokens.");
        
        marketMakers[msg.sender].balances[tokenAddress] -= amount;
        totalTokens[tokenAddress] -= amount;
        
        Token.approve(address(this),amount);// approval given to contract for transfer.
        Token.transferFrom(address(this),msg.sender, amount); // transfering tokens to owner.
        
        
    }
    
     /**  
    *    @dev getThePrice gets price from chainlink
    *    Oracle services.
    *   
    *    
    *
    */
    
    
    function getThePrice(AggregatorV3Interface priceFeed) public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
    
    
     /**  
    *    @dev swap is the heart of the swap, it is used  for swapping 1 ERC20 token with
    *    another ERC20 token, the only way for a swap to happen on this exchange is if 
    *    it has been added by the DAO, the contract will not allow any other token
    *    to be swapped on this platform.
    *
    */
    
    
    function swap(address sendingToken, address receivingToken, uint256 amount) public{
        //need real-time prices
        HW2Token tok1 = HW2Token(sendingToken);
        HW2Token tok2 = HW2Token(receivingToken);
        
        
        // AggregatorV3Interface  priceFeedTok1 = AggregatorV3Interface(sendingToken);
        // AggregatorV3Interface  priceFeedTok2 = AggregatorV3Interface(receivingToken);
        // int256 tok1price = getThePrice(priceFeedTok1);
        // int256 tok2price = getThePrice(priceFeedTok2);
        
        int256 tok1price = 3;
        int256 tok2price = 3;
        uint256 sendingAmount = uint((int(amount) *  tok1price  ) /tok2price );
        // data will come from chainlink.
        // sending amount will be (chainlink data - fees), fees will be transferred to market makers of that kind of token, according to their contrubution.
        uint256 fees = (sendingAmount * 3 / 1000);
        require(approvedTokens[sendingToken] == true);
        require(approvedTokens[receivingToken] == true);
        require(tok1.transferFrom(msg.sender,address(this),amount), "please enter a valid amount");
        uint256 rewards = (( fees *  9)/10);
        swapRewards[receivingToken] += rewards;
        daoSwapRewards[receivingToken] += fees - rewards;
        tok2.approve(address(this),sendingAmount-fees);
        require(tok2.transferFrom(address(this), msg.sender, (sendingAmount -fees)));
        
    }
    
    function sendRewards(address tokenAddress) public onlyDao{
        HW2Token(tokenAddress).approve(DAOaddress,daoSwapRewards[tokenAddress]);
        DAO(DAOaddress).receiveRewards(daoSwapRewards[tokenAddress],tokenAddress);
        //rewarding the market makers.
        uint256 reward = swapRewards[tokenAddress];
        swapRewards[tokenAddress] = 0;
        for(uint256 i= 0; i < marketMakerAddresses.length ; i++){
            marketMakers[marketMakerAddresses[i]].balances[tokenAddress] += ((reward * marketMakers[marketMakerAddresses[i]].balances[tokenAddress]) / totalTokens[tokenAddress]);
        }
    }
    
   
    
    
}
