async function buscarDados() {
    try {
        // Busca o arquivo JSON que está na pasta data
        const resposta = await fetch('./data/ipca.json');
        const dados = await resposta.json();
        
        // Exibe no HTML formatado
        document.getElementById('output').textContent = JSON.stringify(dados, null, 2);
    } catch (erro) {
        document.getElementById('output').textContent = "Erro ao carregar JSON: " + erro;
    }
}

buscarDados();
