// Variável global para armazenar os dados completos
let dadosCompletos = null;
let todasColunas = [];

async function buscarDados() {
    try {
        const resposta = await fetch('./data/dados_macro.json');
        const objeto = await resposta.json();
        
        // Exibe a data da última atualização
        document.getElementById('atualizacao').textContent = 
            `Última atualização: ${objeto.ultima_atualizacao}`;
        
        // Armazena os dados completos
        dadosCompletos = objeto.dados;
        
        // Identifica as colunas disponíveis (todas menos 'data')
        todasColunas = Object.keys(dadosCompletos[0]).filter(col => col !== 'data');
        
        // Preenche os checkboxes de séries
        preencherCheckboxesSeries();
        
        // Define as datas mínima e máxima para os inputs
        definirLimitesData();
        
        // Exibe a tabela inicial (todas as séries, período completo)
        aplicarFiltro();
        
    } catch (erro) {
        document.getElementById('tabelaBody').innerHTML = 
            `<tr><td colspan="10">Erro ao carregar JSON: ${erro}</td></tr>`;
        document.getElementById('atualizacao').textContent = "Erro ao carregar data de atualização.";
    }
}

function preencherCheckboxesSeries() {
    const container = document.getElementById('seriesCheckboxes');
    container.innerHTML = ''; // Limpa
    
    todasColunas.forEach(col => {
        const label = document.createElement('label');
        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.value = col;
        checkbox.checked = true; // Por padrão, todas selecionadas
        label.appendChild(checkbox);
        label.appendChild(document.createTextNode(col));
        container.appendChild(label);
    });
}

function definirLimitesData() {
    if (!dadosCompletos || dadosCompletos.length === 0) return;
    
    // Ordena por data para obter a primeira e última
    const datas = dadosCompletos.map(item => item.data).sort();
    const primeira = datas[0];
    const ultima = datas[datas.length - 1];
    
    document.getElementById('startDate').value = primeira;
    document.getElementById('endDate').value = ultima;
    document.getElementById('startDate').min = primeira;
    document.getElementById('startDate').max = ultima;
    document.getElementById('endDate').min = primeira;
    document.getElementById('endDate').max = ultima;
}

function aplicarFiltro() {
    if (!dadosCompletos) return;
    
    // Obter séries selecionadas (checkboxes marcados)
    const checkboxes = document.querySelectorAll('#seriesCheckboxes input[type="checkbox"]');
    const selectedOptions = [];
    checkboxes.forEach(cb => {
        if (cb.checked) selectedOptions.push(cb.value);
    });
    
    // Se nenhuma selecionada, usa todas (mas isso não deve acontecer se todas estiverem marcadas por padrão)
    const colunasMostrar = selectedOptions.length > 0 ? selectedOptions : todasColunas;
    
    // Obter datas
    let start = document.getElementById('startDate').value;
    let end = document.getElementById('endDate').value;
    
    // Filtrar linhas por período
    let dadosFiltrados = dadosCompletos;
    if (start) {
        dadosFiltrados = dadosFiltrados.filter(item => item.data >= start);
    }
    if (end) {
        dadosFiltrados = dadosFiltrados.filter(item => item.data <= end);
    }
    
    // Criar tabela com as colunas selecionadas
    exibirTabela(dadosFiltrados, ['data', ...colunasMostrar]);
}

function exibirTabela(dados, colunas) {
    const thead = document.getElementById('tabelaHead');
    const tbody = document.getElementById('tabelaBody');
    
    // Cabeçalho
    let headerHtml = '<tr>';
    colunas.forEach(col => {
        headerHtml += `<th>${col}</th>`;
    });
    headerHtml += '</tr>';
    thead.innerHTML = headerHtml;
    
    // Corpo
    let bodyHtml = '';
    dados.forEach(item => {
        bodyHtml += '<tr>';
        colunas.forEach(col => {
            bodyHtml += `<td>${item[col] !== undefined ? item[col] : ''}</td>`;
        });
        bodyHtml += '</tr>';
    });
    
    if (dados.length === 0) {
        bodyHtml = '<tr><td colspan="' + colunas.length + '">Nenhum dado encontrado no período</td></tr>';
    }
    
    tbody.innerHTML = bodyHtml;
}

function exportarExcel() {
    if (!dadosCompletos) return;
    
    // Obter as colunas atualmente exibidas na tabela (do cabeçalho)
    const thead = document.getElementById('tabelaHead');
    if (!thead.rows.length) return;
    const colunas = Array.from(thead.rows[0].cells).map(cell => cell.textContent);
    
    // Obter dados da tabela (tbody)
    const tbody = document.getElementById('tabelaBody');
    const linhas = tbody.rows;
    
    // Construir matriz de dados para o SheetJS
    const dadosExport = [];
    
    // Cabeçalho
    dadosExport.push(colunas);
    
    // Linhas
    for (let i = 0; i < linhas.length; i++) {
        const linha = [];
        const celulas = linhas[i].cells;
        for (let j = 0; j < celulas.length; j++) {
            linha.push(celulas[j].textContent);
        }
        dadosExport.push(linha);
    }
    
    // Criar planilha
    const wb = XLSX.utils.book_new();
    const ws = XLSX.utils.aoa_to_sheet(dadosExport);
    
    // Ajustar largura das colunas para 11 (em unidades de caracteres)
    const colWidths = [];
    for (let i = 0; i < colunas.length; i++) {
        colWidths.push({ wch: 11 }); // wch = largura em número de caracteres
    }
    ws['!cols'] = colWidths;
    
    // Adicionar a planilha ao workbook
    XLSX.utils.book_append_sheet(wb, ws, "Dados");
    
    // Gerar arquivo e baixar
    XLSX.writeFile(wb, "dados_macro.xlsx");
}

// Função para limpar filtros de data e mostrar todo o período
function todasDatas() {
    if (!dadosCompletos) return;
    const datas = dadosCompletos.map(item => item.data).sort();
    const primeira = datas[0];
    const ultima = datas[datas.length - 1];
    document.getElementById('startDate').value = primeira;
    document.getElementById('endDate').value = ultima;
    aplicarFiltro(); // Reaplica o filtro com as datas completas
}

// Eventos
document.getElementById('aplicarFiltro').addEventListener('click', aplicarFiltro);
document.getElementById('exportarExcel').addEventListener('click', exportarExcel);
document.getElementById('todasDatas').addEventListener('click', todasDatas);

// Iniciar
buscarDados();
