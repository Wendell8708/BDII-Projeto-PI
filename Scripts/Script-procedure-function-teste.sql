USE AgroConecta;

-- =========================
-- TESTES DAS PROCEDURES
-- =========================

-- cadGestor_telefone
CALL cadGestor_telefone(
    '009.009.009-09',
    'Gestor 09',
    'gestor09@agro.com',
    'dev_hash',
    'gestor09',
    '(81) 9300-0009'
);

SELECT 
    g.cpf, t.numero
FROM
    gestor g
        JOIN
    telefone t ON g.CPF = t.Gestor_CPF
WHERE
    g.CPf = '009.009.009-09';

-- cadCooperativa_tel_endereco
CALL cadCooperativa_tel_endereco(
    '98.765.432/0001',
    'Cooperativa Agro 99',
    'Responsavel Coop 99',
    '999.888.7799',
    'coop99@agro.com',
    'dev_hash',
    'coop99',
    '(81) 9400-0099',
    'PE',
    'Caruaru',
    'Centro',
    'Rua Projeto',
    300,
    'Galpao Projeto',
    '55100-000'
);

SELECT 
    c.CNPJ, t.numero, e.rua
FROM
    cooperativa c
        JOIN
    telefone t ON t.Cooperativa_CNPJ = c.CNPJ
        JOIN
    endereco e ON e.idEndereco = c.Endereco_idEndereco
WHERE
    c.CNPJ = '98.765.432/0001';

-- cadArmazem_end (usa Gestor já existente)
CALL cadArmazem_end(
    'Armazem Projeto',
    'Armazem de testes das procedures',
    '001.001.001-01',
    'PE',
    'Caruaru',
    'Centro',
    'Rua dos Testes',
    400,
    'Galpao Teste',
    '55200-000'
);

SELECT 

    a.nome,
    e.cidade
FROM
    Armazem a
        JOIN
    Gestor g ON g.CPF = a.Gestor_CPF
        JOIN
    Endereco e ON e.idEndereco = a.Endereco_idEndereco
WHERE
    a.nome = 'Armazem Projeto';


-- cadLote (usa Armazem 1 e TipoSemente 1)
CALL cadLote(
    '2025-05-30',
    '2025-12-31',
    1500,
    1,
    1,
    'QR_TESTE_100'
);

SELECT 
    l.idLote,
    a.nome,
    ts.nome
FROM
    Lote l
        JOIN
    Armazem a ON a.idArmazem = l.Armazem_idArmazem
        JOIN
    TipoSemente ts ON ts.idTipoSemente = l.TipoSemente_idTipoSemente
WHERE
    l.qr_payload = 'QR_TESTE_001';


-- moverLote (move o lote 1 para o armazem 2)
CALL moverLote(1, 2);

SELECT 
    l.idLote, l.qr_payload, a.idArmazem, a.nome AS armazem
FROM
    Lote l
        JOIN
    Armazem a ON a.idArmazem = l.Armazem_idArmazem
WHERE
    l.idLote = 1;



-- =========================
-- TESTES DAS FUNÇÕES
-- =========================

-- caclSolicitacaoCoop(cnpj)
SELECT 
    'Solicitações da cooperativa 12.345.678/0001' AS descricao,
    caclSolicitacaoCoop('12.345.678/0001') AS total_solicitacoes;

-- caclDiasVencimento(id)
SELECT 
    idLote,
    dataVencimento,
    caclDiasVencimento(idLote) AS dias_para_vencer
FROM Lote
ORDER BY idLote
LIMIT 10;


-- calcLoteArmazem(arm)
SELECT 
    a.idArmazem,
    a.nome,
    calcLoteArmazem(a.idArmazem) AS qtd_lotes
FROM Armazem a
ORDER BY a.idArmazem
LIMIT 10;


-- calcTotalPeso(arm)
SELECT 
    a.idArmazem,
    a.nome,
    calcTotalPeso(a.idArmazem) AS peso_total
FROM Armazem a
ORDER BY a.idArmazem
LIMIT 10;


-- calcTotalLoteSemestre(ano, sem)
SELECT 
    2025 AS ano,
    1 AS semestre,
    calcTotalLoteSemestre(2025, 1) AS qtd_lotes_sem1_2025;

SELECT 
    2025 AS ano,
    2 AS semestre,
    calcTotalLoteSemestre(2025, 2) AS qtd_lotes_sem2_2025;


-- caclTotalSolicitacoesSafra(pStatus, pSafra)
SELECT 
    'PENDENTE' AS status_param,
    1 AS idSafra,
    caclTotalSolicitacoesSafra('PENDENTE', 1) AS total_status_safra1;

SELECT 
    'APROVADA' AS status_param,
    3 AS idSafra,
    caclTotalSolicitacoesSafra('APROVADA', 3) AS total_status_safra3;


-- calcPesoSafra(pSafra)
SELECT 
    1 AS idSafra,
    calcPesoSafra(1) AS peso_total_safra1;

SELECT 
    3 AS idSafra,
    calcPesoSafra(3) AS peso_total_safra3;


-- qtdLotesPrestesVencer(pDias)
SELECT 
    30 AS dias,
    qtdLotesPrestesVencer(30) AS lotes_vencem_proximos_30_dias;

SELECT 
    60 AS dias,
    qtdLotesPrestesVencer(60) AS lotes_vencem_proximos_60_dias;


-- percLotesVencidosArmazem(pArm)
SELECT 
    a.idArmazem,
    a.nome,
    percLotesVencidosArmazem(a.idArmazem) AS perc_lotes_vencidos
FROM Armazem a
ORDER BY a.idArmazem;

