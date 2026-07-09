// ===== MATRIX RAIN =====
(function matrixRain() {
    const canvas = document.getElementById('matrix-canvas');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');

    let width, height, columns, drops, characters;

    function resizeCanvas() {
        width = window.innerWidth;
        height = window.innerHeight;
        canvas.width = width;
        canvas.height = height;
        columns = Math.floor(width / 20);
        drops = new Array(columns).fill(1);
        characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789$¥€£₿#@%&*()_+{}:;<>?!'.split('');
    }

    function draw() {
        ctx.fillStyle = 'rgba(18, 18, 18, 0.05)';
        ctx.fillRect(0, 0, width, height);
        ctx.font = '18px monospace';
        ctx.textAlign = 'center';

        for (let i = 0; i < drops.length; i++) {
            const char = characters[Math.floor(Math.random() * characters.length)];
            const brightness = Math.floor(100 + Math.random() * 155);
            ctx.fillStyle = `rgb(0, ${brightness}, 0)`;
            const x = i * 20;
            const y = drops[i] * 20;
            ctx.fillText(char, x, y);
            if (y > height && Math.random() > 0.975) {
                drops[i] = 0;
            }
            drops[i]++;
        }
    }

    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);
    setInterval(draw, 33);

    document.addEventListener('click', () => {
        canvas.style.opacity = '0.6';
        setTimeout(() => canvas.style.opacity = '0.4', 300);
    });
})();

// ===== JOGO DA COBRINHA (SNAKE MONEY) =====
class SnakeGame {
    constructor(canvasId) {
        this.canvas = document.getElementById(canvasId);
        this.ctx = this.canvas.getContext('2d');
        this.gridSize = 20;
        this.tileCount = this.canvas.width / this.gridSize;
        
        this.reset();
        this.setupEventListeners();
        this.gameLoop();
    }

    reset() {
        this.snake = [
            { x: 10, y: 10 }
        ];
        this.direction = { x: 1, y: 0 };
        this.nextDirection = { x: 1, y: 0 };
        this.money = this.generateMoney();
        this.score = 0;
        this.level = 1;
        this.gameOver = false;
        this.gameSpeed = 100; // ms
        this.lastMoveTime = 0;
    }

    generateMoney() {
        let newMoney;
        let isOnSnake = true;
        while (isOnSnake) {
            newMoney = {
                x: Math.floor(Math.random() * this.tileCount),
                y: Math.floor(Math.random() * this.tileCount)
            };
            isOnSnake = this.snake.some(segment => segment.x === newMoney.x && segment.y === newMoney.y);
        }
        return newMoney;
    }

    setupEventListeners() {
        document.addEventListener('keydown', (e) => {
            if (this.gameOver) {
                if (e.key === 'Enter' || e.key === ' ') {
                    this.reset();
                }
                return;
            }

            switch(e.key) {
                case 'ArrowUp':
                case 'w':
                case 'W':
                    if (this.direction.y === 0) this.nextDirection = { x: 0, y: -1 };
                    e.preventDefault();
                    break;
                case 'ArrowDown':
                case 's':
                case 'S':
                    if (this.direction.y === 0) this.nextDirection = { x: 0, y: 1 };
                    e.preventDefault();
                    break;
                case 'ArrowLeft':
                case 'a':
                case 'A':
                    if (this.direction.x === 0) this.nextDirection = { x: -1, y: 0 };
                    e.preventDefault();
                    break;
                case 'ArrowRight':
                case 'd':
                case 'D':
                    if (this.direction.x === 0) this.nextDirection = { x: 1, y: 0 };
                    e.preventDefault();
                    break;
            }
        });
    }

    update(deltaTime) {
        if (this.gameOver) return;

        this.lastMoveTime += deltaTime;
        if (this.lastMoveTime < this.gameSpeed) return;
        this.lastMoveTime = 0;

        this.direction = this.nextDirection;

        const head = this.snake[0];
        const newHead = {
            x: head.x + this.direction.x,
            y: head.y + this.direction.y
        };

        // Verificar colisão com parede
        if (newHead.x < 0 || newHead.x >= this.tileCount || 
            newHead.y < 0 || newHead.y >= this.tileCount) {
            this.gameOver = true;
            return;
        }

        // Verificar colisão com corpo
        if (this.snake.some(segment => segment.x === newHead.x && segment.y === newHead.y)) {
            this.gameOver = true;
            return;
        }

        this.snake.unshift(newHead);

        // Verificar colisão com dinheiro
        if (newHead.x === this.money.x && newHead.y === this.money.y) {
            this.score += 10;
            this.level = Math.floor(this.score / 50) + 1;
            this.gameSpeed = Math.max(50, 100 - this.level * 5);
            this.money = this.generateMoney();
        } else {
            this.snake.pop();
        }
    }

    draw() {
        // Fundo preto
        this.ctx.fillStyle = '#000';
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

        // Grade (estilo Matrix)
        this.ctx.strokeStyle = 'rgba(0, 255, 0, 0.1)';
        this.ctx.lineWidth = 0.5;
        for (let i = 0; i <= this.tileCount; i++) {
            const pos = i * this.gridSize;
            this.ctx.beginPath();
            this.ctx.moveTo(pos, 0);
            this.ctx.lineTo(pos, this.canvas.height);
            this.ctx.stroke();

            this.ctx.beginPath();
            this.ctx.moveTo(0, pos);
            this.ctx.lineTo(this.canvas.width, pos);
            this.ctx.stroke();
        }

        // Desenhar cobra
        this.snake.forEach((segment, index) => {
            if (index === 0) {
                // Cabeça - mais brilhante
                this.ctx.fillStyle = '#00ff00';
                this.ctx.shadowColor = 'rgba(0, 255, 0, 0.8)';
                this.ctx.shadowBlur = 10;
            } else {
                // Corpo - gradualmente mais escuro
                const opacity = 0.7 - (index / this.snake.length) * 0.5;
                this.ctx.fillStyle = `rgba(0, 255, 0, ${opacity})`;
                this.ctx.shadowColor = 'none';
                this.ctx.shadowBlur = 0;
            }

            const x = segment.x * this.gridSize;
            const y = segment.y * this.gridSize;
            this.ctx.fillRect(x + 1, y + 1, this.gridSize - 2, this.gridSize - 2);
        });

        this.ctx.shadowColor = 'none';
        this.ctx.shadowBlur = 0;

        // Desenhar dinheiro ($)
        this.ctx.fillStyle = '#00ff00';
        this.ctx.font = 'bold 16px monospace';
        this.ctx.textAlign = 'center';
        this.ctx.textBaseline = 'middle';
        this.ctx.shadowColor = 'rgba(0, 255, 0, 0.8)';
        this.ctx.shadowBlur = 8;
        const moneyX = this.money.x * this.gridSize + this.gridSize / 2;
        const moneyY = this.money.y * this.gridSize + this.gridSize / 2;
        this.ctx.fillText('$', moneyX, moneyY);
        this.ctx.shadowColor = 'none';
        this.ctx.shadowBlur = 0;

        // Desenhar mensagem de Game Over
        if (this.gameOver) {
            this.ctx.fillStyle = 'rgba(0, 0, 0, 0.7)';
            this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);

            this.ctx.fillStyle = '#00ff00';
            this.ctx.font = 'bold 24px monospace';
            this.ctx.textAlign = 'center';
            this.ctx.textBaseline = 'middle';
            this.ctx.fillText('GAME OVER', this.canvas.width / 2, this.canvas.height / 2 - 30);

            this.ctx.font = '16px monospace';
            this.ctx.fillText(`Score: ${this.score}`, this.canvas.width / 2, this.canvas.height / 2 + 10);
            this.ctx.fillText('Pressione ENTER para recomeçar', this.canvas.width / 2, this.canvas.height / 2 + 40);
        }

        // Atualizar UI
        document.getElementById('snakeScore').textContent = this.score;
        document.getElementById('snakeLevel').textContent = this.level;
        document.getElementById('snakeMoney').textContent = '$' + (this.score);
    }

    gameLoop() {
        const now = Date.now();
        if (!this.lastFrameTime) this.lastFrameTime = now;
        const deltaTime = now - this.lastFrameTime;
        this.lastFrameTime = now;

        this.update(deltaTime);
        this.draw();

        requestAnimationFrame(() => this.gameLoop());
    }
}

let snakeGame = null;

// ===== LÓGICA DO SITE =====
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
    const titleEl = document.querySelector('h1');
    const radarContainer = document.getElementById('radarContainer');
    const snakeModal = document.getElementById('snakeModal');
    const snakeClose = document.getElementById('snakeClose');

    // Event listeners para o jogo da cobrinha
    radarContainer.addEventListener('click', () => {
        snakeModal.classList.add('show');
        if (!snakeGame) {
            snakeGame = new SnakeGame('snakeCanvas');
        } else {
            snakeGame.reset();
        }
    });

    snakeClose.addEventListener('click', () => {
        snakeModal.classList.remove('show');
    });

    snakeModal.addEventListener('click', (e) => {
        if (e.target === snakeModal) {
            snakeModal.classList.remove('show');
        }
    });

    // Título clicável também abre o jogo
    titleEl.addEventListener('click', () => {
        snakeModal.classList.add('show');
        if (!snakeGame) {
            snakeGame = new SnakeGame('snakeCanvas');
        } else {
            snakeGame.reset();
        }
    });

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

    aplicarFiltroBtn.addEventListener('click', aplicarFiltro);
    todasDatasBtn.addEventListener('click', resetarTodasDatas);
    exportarExcelBtn.addEventListener('click', exportarExcel);

    buscarDados();
});
