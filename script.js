async function buscarDados() {
    try {
        const resposta = await fetch('./data/dados_macro.json');
        const objeto = await resposta.json();
        
        // Exibe a data da última atualização
        document.getElementById('atualizacao').textContent = 
            `Última atualização: ${objeto.ultima_atualizacao}`;
        
        // Monta a tabela com os dados
        const dados = objeto.dados;
        let tabelaHtml = '<table border="1" style="border-collapse: collapse; width:100%;">';
        
        // Cabeçalho
        tabelaHtml += '<thead><tr>';
        for (let coluna in dados[0]) {
            tabelaHtml += `<th>${coluna}</th>`;
        }
        tabelaHtml += '</tr></thead><tbody>';
        
        // Linhas de dados
        dados.forEach(linha => {
            tabelaHtml += '<tr>';
            for (let coluna in linha) {
                tabelaHtml += `<td>${linha[coluna]}</td>`;
            }
            tabelaHtml += '</tr>';
        });
        
        tabelaHtml += '</tbody></table>';
        document.getElementById('output').innerHTML = tabelaHtml;
        
    } catch (erro) {
        document.getElementById('output').innerHTML = "Erro ao carregar JSON: " + erro;
        document.getElementById('atualizacao').textContent = "Erro ao carregar data de atualização.";
    }
}

buscarDados();
