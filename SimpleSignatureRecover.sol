pragma solidity ^0.4.0;

contract SimpleSignatureRecover {

    struct ContractDomain {
        string name;
        string version;
        address contAddress;
    }

    ContractDomain contractDomain = ContractDomain("VerifierApp101", '1', 0x8c1eD7e19abAa9f23c476dA86Dc1577F1Ef401f5);
    uint256 constant chainId = 5;

    //    string contractName = "VerifierApp101";
    //    string version = '1';
    //    address verifyingContract = 0x8c1eD7e19abAa9f23c476dA86Dc1577F1Ef401f5;

    struct Unit {
        address to;
        uint256 value;
        uint256 fee;
        uint256 nonce;
    }

    string private constant CONTRACT_DOMAIN = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";
    bytes32 private constant CONTRACT_DOMAIN_TYPEHASH = keccak256(abi.encodePacked(CONTRACT_DOMAIN));
    bytes32 private CONTRACT_DOMAIN_SEPARATOR = keccak256(abi.encode(
            CONTRACT_DOMAIN_TYPEHASH,
            keccak256(contractDomain.name),
            keccak256(contractDomain.version),
            chainId,
            contractDomain.contAddress
        ));

    string private constant UNIT = "Unit(address to,uint256 value,uint256 fee,uint256 nonce)";
    bytes32 private constant UNIT_TYPEHASH = keccak256(abi.encodePacked(UNIT));

    function hashUnit(Unit memory unitobj) private view returns (bytes32) {
        return keccak256(abi.encodePacked(
                "\x19\x01",
                CONTRACT_DOMAIN_SEPARATOR,
                keccak256(abi.encode(
                    UNIT_TYPEHASH,
                    unitobj.to,
                    unitobj.value,
                    unitobj.fee,
                    unitobj.nonce
                ))
            ));
    }

    function testVerify(bytes32 s, bytes32 r, uint8 v, address to, uint256 value, uint256 fee, uint256 nonce) public view returns (address) {
        Unit memory unitObj = Unit({
        to : to,
        value : value,
        fee : fee,
        nonce : nonce
        });
        return ecrecover(hashUnit(unitObj), v, r, s);
    }
}
