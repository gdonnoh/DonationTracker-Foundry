let contract;
let signer;
const contractAddress = '0x8C8A01573dfD8b16632dA8c534D888BbC3F5AD77'; // Indirizzo del contratto

const contractABI = [
    {
      "inputs": [],
      "name": "owner",
      "outputs": [{ "internalType": "address", "name": "", "type": "address" }],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "donate",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "getMoneyInTheContract",
      "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
      "stateMutability": "view",
      "type": "function"
    },
    {
        "inputs": [
          {
            "internalType": "uint256",
            "name": "amount",
            "type": "uint256"
          }
        ],
        "name": "ownerWithdraw",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      }
      
  ];
  

async function connectWallet() {
    if (window.ethereum) {
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        await provider.send("eth_requestAccounts", []);
        signer = provider.getSigner();
        const userAddress = await signer.getAddress();

        contract = new ethers.Contract(contractAddress, contractABI, signer);
        const ownerAddress = await contract.owner();

        // Mostra il bottone solo se l'utente è owner
        if (userAddress.toLowerCase() === ownerAddress.toLowerCase()) {
            document.getElementById("withdrawAmount").style.display = "inline-block";
            document.getElementById("withdrawButton").style.display = "inline-block";
            document.getElementById("getContractBalance").style.display = "inline-block";
        }

        console.log("Connesso:", userAddress);
        document.getElementById("walletAddress").textContent = userAddress;
    } else {
        alert("Installa MetaMask.");
    }
}


async function donate() {
    const amountInput = document.getElementById("donationAmount");
    const amount = amountInput.value;

    if (!amount || isNaN(amount) || Number(amount) <= 0) {
        alert("Inserisci un importo valido in ETH.");
        return;
    }

    try {
        const tx = await contract.donate({
            value: ethers.utils.parseEther(amount)
        });
        await tx.wait();
        alert("Donazione completata!");
        amountInput.value = ""; // Reset
    } catch (err) {
        console.error("Errore nella donazione:", err);
        alert("Errore nella donazione.");
    }
}

async function ownerWithdraw() {
    const amountInput = document.getElementById("withdrawAmount").value;
    if (!amountInput || isNaN(amountInput) || Number(amountInput) <= 0) {
        alert("Inserisci un importo valido da prelevare.");
        return;
    }

    try {
        const amount = ethers.utils.parseEther(amountInput.toString()); 
        const tx = await contract.ownerWithdraw(amount);
        await tx.wait();
        alert("Fondi prelevati!");
    } catch (err) {
        console.error("Errore nel prelievo:", err);
        alert("Errore nel prelievo.");
    }
}


async function getMoneyInTheContract() {
    try {
        const balance = await contract.getMoneyInTheContract();
        const etherBalance = ethers.utils.formatEther(balance);
        document.getElementById("contractBalance").innerText = etherBalance + " ETH";
    } catch (err) {
        console.error("Errore nel recupero del balance:", err);
    }
}
