async function buscarDados() {
    try {
        // Busca o arquivo JSON que está na pasta data
        const resposta = await fetch('./data/ipca.json');
        const objeto = await resposta.json(); // Agora é um objeto com metadados
        
        // Exibe a data da última atualização
        const atualizacao = objeto.ultima_atualizacao || "desconhecida";
        document.getElementById('atualizacao').textContent = `Última atualização: ${atualizacao}`;
        
        // Exibe os dados (agora dentro de objeto.dados)
        document.getElementById('output').textContent = JSON.stringify(objeto.dados, null, 2);
    } catch (erro) {
        document.getElementById('output').textContent = "Erro ao carregar JSON: " + erro;
        document.getElementById('atualizacao').textContent = "Erro ao carregar data de atualização.";
    }
}

buscarDados();
