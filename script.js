/**
 * script.js - Controle da interface de dados macroeconômicos
 * 
 * Funções:
 * - Buscar dados do arquivo JSON
 * - Filtrar por séries e período
 * - Exibir tabela interativa
 * - Exportar para Excel com formatação verde-oliva
 */

// Aguarda o carregamento completo do DOM para evitar erros de elementos não encontrados
document.addEventListener('DOMContentLoaded', function() {

    // ========== VARIÁVEIS GLOBAIS ==========
    let dadosCompletos = null;          // Armazena todos os dados carregados do JSON
    let todasColunas = [];               // Nomes de todas as séries disponíveis (exceto 'data')

    // ========== ELEMENTOS DO DOM ==========
    const atualizacaoEl = document.getElementById('atualizacao');
    const seriesCheckboxesDiv = document.getElementById('seriesCheckboxes');
    const startDateInput = document.getElementById('startDate');
    const endDateInput = document.getElementById('endDate');
    const aplicarFiltroBtn = document.getElementById('aplicarFiltro');
    const todasDatasBtn = document.getElementById('todasDatas');
    const exportarExcelBtn = document.getElementById('exportarExcel');
    const tabelaHead = document.getElementById('tabelaHead');
    const tabelaBody = document.getElementById('tabelaBody');

    // ========== FUNÇÕES ==========

    /**
     * Busca o arquivo JSON e inicializa a interface.
     * É a primeira função chamada ao carregar a página.
     */
    async function buscarDados() {
        try {
            // Faz o fetch do arquivo gerado pela GitHub Action
            const resposta = await fetch('./data/dados_macro.json');
            const objeto = await resposta.json();

            // Exibe a data da última atualização (vinda do JSON)
            atualizacaoEl.textContent = `Última atualização: ${objeto.ultima_atualizacao}`;

            // Armazena os dados completos
            dadosCompletos = objeto.dados;

            // Extrai os nomes das colunas (todas exceto 'data')
            todasColunas = Object.keys(dadosCompletos[0]).filter(col => col !== 'data');

            // Preenche os checkboxes com as séries disponíveis
            preencherCheckboxes();

            // Define os limites mínimo e máximo para os inputs de data
            definirLimitesData();

            // Exibe a tabela inicial (todas as séries, período completo)
            aplicarFiltro();

        } catch (erro) {
            // Em caso de erro, mostra mensagem na tabela
            tabelaBody.innerHTML = `<tr><td colspan="10">Erro ao carregar JSON: ${erro}</td></tr>`;
            atualizacaoEl.textContent = "Erro ao carregar data de atualização.";
        }
    }

    /**
     * Cria dinamicamente os checkboxes para cada série.
     * Todos vêm marcados por padrão.
     */
    function preencherCheckboxes() {
        seriesCheckboxesDiv.innerHTML = ''; // Limpa o conteúdo anterior

        todasColunas.forEach(col => {
            // Cria um label que envolve o checkbox e o nome
            const label = document.createElement('label');
            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.value = col;
            checkbox.checked = true; // Por padrão, todas selecionadas

            label.appendChild(checkbox);
            label.appendChild(document.createTextNode(col));
            seriesCheckboxesDiv.appendChild(label);
        });
    }

    /**
     * Define os valores mínimo e máximo para os inputs de data,
     * baseados nas datas disponíveis nos dados.
     */
    function definirLimitesData() {
        if (!dadosCompletos || dadosCompletos.length === 0) return;

        // Obtém todas as datas e ordena
        const datas = dadosCompletos.map(item => item.data).sort();
        const primeira = datas[0];
        const ultima = datas[datas.length - 1];

        // Define valores padrão (todo o período)
        startDateInput.value = primeira;
        endDateInput.value = ultima;

        // Define os limites que o usuário pode escolher
        startDateInput.min = primeira;
        startDateInput.max = ultima;
        endDateInput.min = primeira;
        endDateInput.max = ultima;
    }

    /**
     * Aplica os filtros selecionados (séries e período) e atualiza a tabela.
     */
    function aplicarFiltro() {
        if (!dadosCompletos) return;

        // Obtém as séries marcadas nos checkboxes
        const checkboxes = document.querySelectorAll('#seriesCheckboxes input[type="checkbox"]:checked');
        const colunasMostrar = Array.from(checkboxes).map(cb => cb.value);

        // Se nenhuma estiver marcada (improvável), mostra todas
        const colunasExibir = colunasMostrar.length > 0 ? colunasMostrar : todasColunas;

        // Obtém as datas selecionadas
        const start = startDateInput.value;
        const end = endDateInput.value;

        // Filtra as linhas pelo período
        let dadosFiltrados = dadosCompletos;
        if (start) {
            dadosFiltrados = dadosFiltrados.filter(item => item.data >= start);
        }
        if (end) {
            dadosFiltrados = dadosFiltrados.filter(item => item.data <= end);
        }

        // Monta a tabela com as colunas escolhidas e os dados filtrados
        exibirTabela(dadosFiltrados, ['data', ...colunasExibir]);
    }

    /**
     * Exibe os dados na tabela HTML.
     * @param {Array} dados - Array de objetos com os dados a serem exibidos
     * @param {Array} colunas - Lista de nomes de colunas a incluir (a primeira é sempre 'data')
     */
    function exibirTabela(dados, colunas) {
        // Gera o cabeçalho
        let headerHtml = '<tr>';
        colunas.forEach(col => {
            headerHtml += `<th>${col}</th>`;
        });
        headerHtml += '</tr>';
        tabelaHead.innerHTML = headerHtml;

        // Gera as linhas de dados
        let bodyHtml = '';
        dados.forEach(item => {
            bodyHtml += '<tr>';
            colunas.forEach(col => {
                bodyHtml += `<td>${item[col] !== undefined ? item[col] : ''}</td>`;
            });
            bodyHtml += '</tr>';
        });

        // Caso não haja dados no período
        if (dados.length === 0) {
            bodyHtml = '<tr><td colspan="' + colunas.length + '">Nenhum dado encontrado no período</td></tr>';
        }

        tabelaBody.innerHTML = bodyHtml;
    }

    /**
     * Exporta os dados atualmente exibidos na tabela para um arquivo Excel (.xlsx)
     * com formatação especial: cabeçalho verde-oliva, células verde-oliva claro, bordas.
     */
    async function exportarExcel() {
        if (!dadosCompletos) return;

        // Obtém as colunas do cabeçalho atual da tabela
        const colunas = Array.from(tabelaHead.rows[0].cells).map(cell => cell.textContent);

        // Obtém as linhas de dados (tbody)
        const linhas = tabelaBody.rows;

        // Cria uma nova planilha usando ExcelJS
        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('Dados');

        // Define a largura de todas as colunas como 11 (padrão Excel)
        worksheet.columns = colunas.map(() => ({ width: 11 }));

        // Cores em formato ARGB (AARRGGBB) - FF = opacidade total
        const corVerdeOliva = 'FF6B8E23';       // verde-oliva ênfase 3
        const corVerdeOlivaClaro = 'FFB0C47F';  // 60% mais claro (aproximado)
        const corBorda = 'FF6B8E23';            // mesma cor para bordas

        // Estilo do cabeçalho (fundo verde-oliva, texto branco, negrito, bordas)
        const headerStyle = {
            fill: {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: corVerdeOliva }
            },
            font: { color: { argb: 'FFFFFFFF' }, bold: true },
            border: {
                top: { style: 'thin', color: { argb: corBorda } },
                left: { style: 'thin', color: { argb: corBorda } },
                bottom: { style: 'thin', color: { argb: corBorda } },
                right: { style: 'thin', color: { argb: corBorda } }
            },
            alignment: { horizontal: 'left' }
        };

        // Estilo das células de dados (fundo claro, texto preto, bordas)
        const dataStyle = {
            fill: {
                type: 'pattern',
                pattern: 'solid',
                fgColor: { argb: corVerdeOlivaClaro }
            },
            font: { color: { argb: 'FF000000' } }, // preto
            border: {
                top: { style: 'thin', color: { argb: corBorda } },
                left: { style: 'thin', color: { argb: corBorda } },
                bottom: { style: 'thin', color: { argb: corBorda } },
                right: { style: 'thin', color: { argb: corBorda } }
            },
            alignment: { horizontal: 'left' }
        };

        // Adiciona a linha de cabeçalho e aplica o estilo
        const headerRow = worksheet.addRow(colunas);
        headerRow.eachCell(cell => {
            cell.style = headerStyle;
        });

        // Adiciona cada linha de dados e aplica o estilo
        for (let i = 0; i < linhas.length; i++) {
            const linha = [];
            for (let j = 0; j < linhas[i].cells.length; j++) {
                linha.push(linhas[i].cells[j].textContent);
            }
            const dataRow = worksheet.addRow(linha);
            dataRow.eachCell(cell => {
                cell.style = dataStyle;
            });
        }

        // Gera o arquivo Excel como buffer e cria um blob para download
        const buffer = await workbook.xlsx.writeBuffer();
        const blob = new Blob([buffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = 'dados_macro.xlsx';
        link.click();
        URL.revokeObjectURL(link.href); // Libera memória
    }

    /**
     * Reseta os filtros de data para o período completo (primeira e última data disponível).
     */
    function resetarTodasDatas() {
        if (!dadosCompletos) return;
        const datas = dadosCompletos.map(item => item.data).sort();
        startDateInput.value = datas[0];
        endDateInput.value = datas[datas.length - 1];
        aplicarFiltro(); // Reaplica o filtro com o novo período
    }

    // ========== EVENT LISTENERS ==========
    aplicarFiltroBtn.addEventListener('click', aplicarFiltro);
    todasDatasBtn.addEventListener('click', resetarTodasDatas);
    exportarExcelBtn.addEventListener('click', exportarExcel);

    // ========== INICIALIZAÇÃO ==========
    buscarDados();

}); // Fim do DOMContentLoaded
