document.addEventListener('DOMContentLoaded', () => {
    const connectButton = document.getElementById('connectButton');
    const rollDiceButtonVRF = document.getElementById('rollDiceButtonVRF');
    const statusText = document.getElementById('status');
    const diceResultVRF = document.getElementById('diceResultVRF');
    // 스마트 컨트랙트 ABI와 주소
    const contractAddress = "0x750113E33A68f8C62b7a01Fd73C30AB9f5D621fC"; 
    const contractABI = [
        {
            "inputs": [
                {
                    "internalType": "uint64",
                    "name": "subscriptionId",
                    "type": "uint64"
                }
            ],
            "stateMutability": "nonpayable",
            "type": "constructor"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "have",
                    "type": "address"
                },
                {
                    "internalType": "address",
                    "name": "want",
                    "type": "address"
                }
            ],
            "name": "OnlyCoordinatorCanFulfill",
            "type": "error"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "from",
                    "type": "address"
                },
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "to",
                    "type": "address"
                }
            ],
            "name": "OwnershipTransferRequested",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "from",
                    "type": "address"
                },
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "to",
                    "type": "address"
                }
            ],
            "name": "OwnershipTransferred",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": false,
                    "internalType": "uint256",
                    "name": "requestId",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "internalType": "uint256[]",
                    "name": "randomWords",
                    "type": "uint256[]"
                }
            ],
            "name": "RequestFulfilled",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": false,
                    "internalType": "uint256",
                    "name": "requestId",
                    "type": "uint256"
                },
                {
                    "indexed": false,
                    "internalType": "uint32",
                    "name": "numWords",
                    "type": "uint32"
                }
            ],
            "name": "RequestSent",
            "type": "event"
        },
        {
            "inputs": [],
            "name": "acceptOwnership",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "_requestId",
                    "type": "uint256"
                }
            ],
            "name": "getRequestStatus",
            "outputs": [
                {
                    "internalType": "bool",
                    "name": "fulfilled",
                    "type": "bool"
                },
                {
                    "internalType": "uint256",
                    "name": "randomWords",
                    "type": "uint256"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "lastRequestId",
            "outputs": [
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "owner",
            "outputs": [
                {
                    "internalType": "address",
                    "name": "",
                    "type": "address"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "requestId",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256[]",
                    "name": "randomWords",
                    "type": "uint256[]"
                }
            ],
            "name": "rawFulfillRandomWords",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                }
            ],
            "name": "requestIds",
            "outputs": [
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "requestRandomWords",
            "outputs": [
                {
                    "internalType": "uint256",
                    "name": "requestId",
                    "type": "uint256"
                }
            ],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                }
            ],
            "name": "s_requests",
            "outputs": [
                {
                    "internalType": "bool",
                    "name": "fulfilled",
                    "type": "bool"
                },
                {
                    "internalType": "bool",
                    "name": "exists",
                    "type": "bool"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "to",
                    "type": "address"
                }
            ],
            "name": "transferOwnership",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        }
    ];
    let contract;
    
    if (window.ethereum) {
        window.web3 = new Web3(window.ethereum);
        contract = new web3.eth.Contract(contractABI, contractAddress);
    } else {
        console.log('MetaMask is not installed!');
    }

    connectButton.addEventListener('click', async () => {
        try {
            // MetaMask에 연결 요청
            await window.ethereum.request({ method: 'eth_requestAccounts' });
            console.log('Connected to MetaMask');
            statusText.textContent = 'Connected';
            connectButton.disabled = true; // 연결 후 버튼 비활성화
            rollDiceButtonVRF.disabled = false; // 연결 후 주사위 굴리기 버튼 활성화
        } catch (error) {
            console.error('Error connecting to MetaMask:', error);
        }
    });
    
    rollDiceButtonVRF.addEventListener('click', async () => {
        try {
            const accounts = await web3.eth.getAccounts();
            const account = accounts[0];
            console.log('Account:', account);
            // 스마트 컨트랙트의 requestRandomWords 함수 호출
            const receipt = await contract.methods.requestRandomWords().send({ from: account });
            console.log('Receipt:', receipt);
            const lastRequestId = receipt.events.RequestSent.returnValues[0];
            console.log('Last Request ID:', lastRequestId);

            // 결과를 받아오기 위한 대기 로직
            let randomValue;
            const checkInterval = setInterval(async () => {
                randomValue = await contract.methods.getRequestStatus(lastRequestId).call();

                if (randomValue !== '0') {
                    clearInterval(checkInterval);
                    console.log('Random Value:', randomValue[1]);

                    // 여기서 랜덤 값에 대한 추가 처리를 수행하세요.
                    diceResultVRF.textContent = `${randomValue[1]}`;
                }
            }, 3000);
        } catch (error) {
            console.error('Error:', error);
        }
    });
    
});



/*

// Meta mask 연결하고 랜덤으로 주사위 굴리기
document.addEventListener('DOMContentLoaded', async () => {

    const connectButton = document.getElementById('connectButton');
    const statusText = document.getElementById('status');
    const rollDiceButton = document.getElementById('rollDiceButton');
    const rollDiceButtonVRF = document.getElementById('rollDiceButtonVRF');
    const diceResultText = document.getElementById('diceResult');
    // Connect to the local Ethereum node using Web3.js
    connectButton.addEventListener('click', async () => {
        // Connect to MetaMask
        if (window.ethereum) {
            try {
                // Request account access
                await window.ethereum.request({ method: 'eth_requestAccounts' });
                statusText.textContent = 'Connected';
                connectButton.disabled = true; // 연결 후 버튼 비활성화
                rollDiceButton.disabled = false; // 주사위 굴리기 버튼 활성화
                rollDiceButtonVRF.disabled = false;
            } catch (error) {
                statusText.textContent = 'Error connecting...';
                console.error(error);
            }
        } else {
            statusText.textContent = 'MetaMask not available!';
            console.error('No Ethereum provider detected.');
        }
    });

    rollDiceButton.addEventListener('click', () => {
        const result = 1 + Math.floor(Math.random() * 6); // 1과 6 사이의 랜덤 숫자 생성
        diceResultText.textContent = `Dice result: ${result}`;
    });
});

*/

// infura.io에서 제공하는 RPC node 주소
// const web3 = new Web3('https://ethereum-sepolia-rpc.allthatnode.com/zUiZgrQsCG3567inpkMRI5GGW1PA8gSL');