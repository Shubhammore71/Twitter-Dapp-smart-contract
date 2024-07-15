// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Twitter{

    struct Tweet{
        uint ID;
        address author;
        string content;
        uint time;
    }

    struct Message{
        uint ID;
        string content;
        address sender;
        address reciever;
        uint time;
    }


    mapping(uint=>Tweet) public tweets;
    mapping(address=>uint[])  public tweetsOf;
    mapping(uint=>Message[]) public conversations;
    mapping(address=>mapping(address=>bool)) public operators;
    mapping (address=>mapping(address=>bool)) public  isFollowing;
    mapping (address=>address[]) public following;

    uint  nextTweetId;
    uint  nextMsgId;

    modifier onlyAuthorized(address _from) {
        require(msg.sender == _from || operators[_from][msg.sender], "You don't have access to perform this action!");
        _;
    }


    function _tweet(address _from,string memory _content) internal 
    {

        tweets[nextTweetId]=Tweet({
            ID:nextTweetId,
            author: _from,
            content: _content,
            time: block.timestamp
        });
        tweetsOf[_from].push(nextTweetId);
        nextTweetId++;

    }

    function _sendMessage(address _from,address _to, string memory _content) internal
    {
        conversations[nextMsgId].push(Message({
            ID:nextMsgId,
            content:_content,
            sender:_from,
            reciever:_to,
            time:block.timestamp
        }));
        nextMsgId++;
    }

    function tweet(string memory _content) public  //owner
    {
        _tweet(msg.sender, _content);
    }

    function tweet(address _from,string memory _content) public  onlyAuthorized(_from)  //operators
    {
        _tweet(_from, _content);
    }

    function sendMessage(string memory _content, address _to) public  //owner
    {
        _sendMessage(msg.sender, _to, _content);
    }

    function sendMessage(address _from,address _to, string memory _content) public onlyAuthorized(_from) //operator 
    {
        _sendMessage(_from, _to, _content);
    }

    function follow(address _followed) public 
    {
        require(!isFollowing[msg.sender][_followed], "You are already following this user");
        isFollowing[msg.sender][_followed] = true;
        following[msg.sender].push(_followed);
    }

    function unFollow(address _followed) public 
    {
        require(isFollowing[msg.sender][_followed], "You are already unfollowing this user");
        isFollowing[msg.sender][_followed] = false;

        uint n=following[msg.sender].length;
        for(uint i=0;i<n;i++){
            if(following[msg.sender][i]==_followed){
                delete  following[msg.sender][i];
            }
        }

    }

    function allow(address _operator) public 
    {
        operators[msg.sender][_operator]=true;
    }

    function disallow(address _operator) public 
    {
        operators[msg.sender][_operator]=false;
    }

    function getLatestTweets(uint count) public view returns (Tweet[] memory) {
        require(count > 0 && count <= nextTweetId, "Count is invalid");
        Tweet[] memory _tweets = new Tweet[](count);
        for (uint i = 0; i < count; i++) {
            _tweets[i] = tweets[nextTweetId - 1 - i];
        }
        return _tweets;
    }

    function getLatestTweetsOf(address user, uint count) public view returns (Tweet[] memory) {
        uint n = tweetsOf[user].length;
        require(count > 0 && count <= n, "Count is invalid");
        Tweet[] memory _tweets = new Tweet[](count);
        for (uint i = 0; i < count; i++) {
            _tweets[i] = tweets[tweetsOf[user][n - 1 - i]];
        }
        return _tweets;
    }

}
