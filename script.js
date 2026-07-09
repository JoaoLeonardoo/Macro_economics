// Aguarda o carregamento completo do DOM
document.addEventListener('DOMContentLoaded', function() {
    let dadosCompletos = null;
    let todasColunas = [];

    const atualizacaoEl = document.getElementById('atualizacao');
    const seriesCheckboxesDiv = document.getElementById('seriesCheckboxes');
    const startDateInput = document.getElementById('startDate');
    const endDateInput = document.getElementById('endDate');
    const aplicarFiltroBtn = document.getElementById('aplicarFiltro');
    const todasDatasBtn = document.getElementById('todasDatas');
    const exportarExcelBtn = document.getElementById('exportarExcel');
    const tabelaHead = document.getElementById('tabelaHead');
    const tabelaBody = document.getElementById('tabelaBody');

    // Função para pausar/retomar a animação da cobra (efeito visual)
    function toggleCobra(pausar) {
        const caminho = document.getElementById('caminho-cobra');
        if (caminho) {
            caminho.style.animationPlayState = pausar ? 'paused' : 'running';
        }
    }

    async function buscarDados() {
        try {
            const resposta = await fetch('./data/dados_macro.json');
            const objeto = await resposta.json();
            atualizacaoEl.textContent = `Última atualização: ${objeto.ultima_atualizacao}`;
            dadosCompletos = objeto.dados;
            todasColunas = Object.keys(dadosCompletos[0]).filter(col => col !== 'data');
            preencherCheckboxes();
            definirLimitesData();
            aplicarFiltro();
        } catch (erro) {
            tabelaBody.innerHTML = `<tr><td colspan="10">Erro ao carregar JSON: ${erro}</td></tr>`;
            atualizacaoEl.textContent = "Erro ao carregar data de atualização.";
        }
    }

    function preencherCheckboxes() {
        seriesCheckboxesDiv.innerHTML = '';
        todasColunas.forEach(col => {
            const label = document.createElement('label');
            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.value = col;
            checkbox.checked = true;
            label.appendChild(checkbox);
            label.appendChild(document.createTextNode(col));
            seriesCheckboxesDiv.appendChild(label);
        });
    }

    function definirLimitesData() {
        if (!dadosCompletos || dadosCompletos.length === 0) return;
        const datas = dadosCompletos.map(item => item.data).sort();
        const primeira = datas[0];
        const ultima = datas[datas.length - 1];
        startDateInput.value = primeira;
        endDateInput.value = ultima;
        startDateInput.min = primeira;
        startDateInput.max = ultima;
        endDateInput.min = primeira;
        endDateInput.max = ultima;
    }

    function aplicarFiltro() {
        if (!dadosCompletos) return;
        // Pausa a cobra durante o processamento (efeito)
        toggleCobra(true);
        setTimeout(() => toggleCobra(false), 500);

        const checkboxes = document.querySelectorAll('#seriesCheckboxes input[type="checkbox"]:checked');
        const colunasMostrar = Array.from(checkboxes).map(cb => cb.value);
        const colunasExibir = colunasMostrar.length > 0 ? colunasMostrar : todasColunas;
        const start = startDateInput.value;
        const end = endDateInput.value;
        let dadosFiltrados = dadosCompletos;
        if (start) dadosFiltrados = dadosFiltrados.filter(item => item.data >= start);
        if (end) dadosFiltrados = dadosFiltrados.filter(item => item.data <= end);
        exibirTabela(dadosFiltrados, ['data', ...colunasExibir]);
    }

    function exibirTabela(dados, colunas) {
        let headerHtml = '<tr>';
        colunas.forEach(col => headerHtml += `<th>${col}</th>`);
        headerHtml += '</tr>';
        tabelaHead.innerHTML = headerHtml;

        let bodyHtml = '';
        dados.forEach(item => {
            bodyHtml += '<tr>';
            colunas.forEach(col => bodyHtml += `<td>${item[col] !== undefined ? item[col] : ''}</td>`);
            bodyHtml += '</tr>';
        });
        if (dados.length === 0) {
            bodyHtml = '<tr><td colspan="' + colunas.length + '">Nenhum dado encontrado</td></tr>';
        }
        tabelaBody.innerHTML = bodyHtml;
    }

    async function exportarExcel() {
        if (!dadosCompletos) return;

        const colunas = Array.from(tabelaHead.rows[0].cells).map(cell => cell.textContent);
        const linhas = tabelaBody.rows;

        const workbook = new ExcelJS.Workbook();
        const worksheet = workbook.addWorksheet('Dados');
        worksheet.columns = colunas.map(() => ({ width: 11 }));

        const corVerdeOliva = 'FF6B8E23';
        const corVerdeOlivaClaro = 'FFB0C47F';
        const corBorda = 'FF6B8E23';

        const headerStyle = {
            fill: { type: 'pattern', pattern: 'solid', fgColor: { argb: corVerdeOliva } },
            font: { color: { argb: 'FFFFFFFF' }, bold: true },
            border: {
                top: { style: 'thin', color: { argb: corBorda } },
                left: { style: 'thin', color: { argb: corBorda } },
                bottom: { style: 'thin', color: { argb: corBorda } },
                right: { style: 'thin', color: { argb: corBorda } }
            },
            alignment: { horizontal: 'left' }
        };

        const dataStyle = {
            fill: { type: 'pattern', pattern: 'solid', fgColor: { argb: corVerdeOlivaClaro } },
            font: { color: { argb: 'FF000000' } },
            border: {
                top: { style: 'thin', color: { argb: corBorda } },
                left: { style: 'thin', color: { argb: corBorda } },
                bottom: { style: 'thin', color: { argb: corBorda } },
                right: { style: 'thin', color: { argb: corBorda } }
            },
            alignment: { horizontal: 'left' }
        };

        const headerRow = worksheet.addRow(colunas);
        headerRow.eachCell(cell => cell.style = headerStyle);

        for (let i = 0; i < linhas.length; i++) {
            const linha = [];
            for (let j = 0; j < linhas[i].cells.length; j++) {
                linha.push(linhas[i].cells[j].textContent);
            }
            const dataRow = worksheet.addRow(linha);
            dataRow.eachCell(cell => cell.style = dataStyle);
        }

        const buffer = await workbook.xlsx.writeBuffer();
        const blob = new Blob([buffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = 'dados_macro.xlsx';
        link.click();
        URL.revokeObjectURL(link.href);
    }

    function resetarTodasDatas() {
        if (!dadosCompletos) return;
        const datas = dadosCompletos.map(item => item.data).sort();
        startDateInput.value = datas[0];
        endDateInput.value = datas[datas.length - 1];
        aplicarFiltro();
    }

    // Event listeners
    aplicarFiltroBtn.addEventListener('click', aplicarFiltro);
    todasDatasBtn.addEventListener('click', resetarTodasDatas);
    exportarExcelBtn.addEventListener('click', exportarExcel);

    // Iniciar
    buscarDados();
});
