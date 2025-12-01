-- VIEWS DO PROJETO AGRO CONECTA

CREATE OR REPLACE VIEW vw_armazem_gestor AS
    SELECT 
        arm.nome AS armazem, g.nome AS gestor
    FROM
        Armazem arm
            JOIN
        Gestor g ON arm.Gestor_CPF = g.CPF;

CREATE OR REPLACE VIEW vw_cooperativas_endereco AS
    SELECT 
        c.RazaoSocial, e.Cidade, e.Bairro, e.Numero
    FROM
        Cooperativa c
            JOIN
        Endereco e ON c.Endereco_idEndereco = e.idEndereco;

CREATE OR REPLACE VIEW vw_lotes_com_tipo_armazem AS
    SELECT 
        l.idLote, ts.nome AS Tipo, arm.nome AS Armazem
    FROM
        Lote l
            JOIN
        TipoSemente ts ON l.TipoSemente_idTipoSemente = ts.idTipoSemente
            JOIN
        Armazem arm ON l.Armazem_idArmazem = arm.idArmazem;

CREATE OR REPLACE VIEW vw_qtd_lotes_por_armazem AS
    SELECT 
        arm.nome AS Armazem, COUNT(l.idLote) AS Total_Lotes
    FROM
        Armazem arm
            LEFT JOIN
        Lote l ON l.Armazem_idArmazem = arm.idArmazem
    GROUP BY arm.idArmazem;

CREATE OR REPLACE VIEW vw_solicitacoes_por_cooperativa AS
    SELECT 
        coop.RazaoSocial,
        COUNT(s.idSolicitacao) AS Total_Solicitacoes
    FROM
        Solicitacao s
            JOIN
        Cooperativa coop ON s.Cooperativa_CNPJ = coop.CNPJ
    GROUP BY coop.CNPJ;

CREATE OR REPLACE VIEW vw_solicitacoes_status AS
    SELECT 
        s.idSolicitacao AS IdSolicitacao, st.nome AS Status
    FROM
        Solicitacao s
            JOIN
        Status st ON s.Status_idStatus = st.idStatus;

CREATE OR REPLACE VIEW vw_solicitacoes_por_tipo AS
    SELECT 
        coop.RazaoSocial, ts.nome AS Tipo, sts.Quantidade
    FROM
        SolicitacaoTipoSemente sts
            JOIN
        TipoSemente ts ON sts.TipoSemente_idTipoSemente = ts.idTipoSemente
            JOIN
        Solicitacao s ON sts.Solicitacao_idSolicitacao = s.idSolicitacao
            JOIN
        Cooperativa coop ON s.Cooperativa_CNPJ = coop.CNPJ;

CREATE OR REPLACE VIEW vw_telefones_gestores AS
    SELECT 
        g.Nome, tel.Numero
    FROM
        Gestor g
            JOIN
        Telefone tel ON tel.Gestor_CPF = g.CPF;

CREATE OR REPLACE VIEW vw_operadores_armazem AS
    SELECT 
        ope.nome AS Operador, arm.nome AS Armazem
    FROM
        OperadorArmazem ope
            JOIN
        Armazem arm ON ope.idOperadorArmazem = arm.OperadorArmazem_idOperadorArmazem;

CREATE OR REPLACE VIEW vw_peso_total_por_tipo AS
    SELECT 
        ts.nome AS Tipo, SUM(l.peso) AS Peso_Total
    FROM
        Lote l
            JOIN
        TipoSemente ts ON l.TipoSemente_idTipoSemente = ts.idTipoSemente
    GROUP BY ts.idTipoSemente;

CREATE OR REPLACE VIEW vw_lotes_vencimento_60dias AS
    SELECT 
        idLote,
        DATE_FORMAT(DataVencimento, '%d/%m/%Y') AS DataVencimento
    FROM
        Lote
    WHERE
        DATEDIFF(dataVencimento, CURDATE()) < 60;

CREATE OR REPLACE VIEW vw_cooperativas_por_cidade AS
    SELECT 
        e.Cidade, COUNT(coop.CNPJ) AS TotalCooperativas
    FROM
        Cooperativa coop
            JOIN
        Endereco e ON coop.Endereco_idEndereco = e.idEndereco
    GROUP BY e.Cidade;

CREATE OR REPLACE VIEW vw_solicitacoes_aprovadas AS
    SELECT 
        s.idSolicitacao, coop.razaoSocial
    FROM
        Solicitacao s
            JOIN
        Cooperativa coop ON s.Cooperativa_CNPJ = coop.CNPJ
    WHERE
        s.Status_idStatus IN (SELECT 
                idStatus
            FROM
                Status
            WHERE
                nome = 'Aprovada');

CREATE OR REPLACE VIEW vw_cooperativas_com_multiplos_telefones AS
    SELECT 
        coop.razaoSocial,
        COUNT(tel.idTelefone) AS QuantidadeTelefones
    FROM
        Cooperativa coop
            JOIN
        Telefone tel ON coop.CNPJ = tel.Cooperativa_CNPJ
    GROUP BY coop.CNPJ
    HAVING COUNT(tel.idTelefone) > 1;

CREATE OR REPLACE VIEW vw_lotes_acima_media AS
    SELECT 
        idLote, peso
    FROM
        Lote
    WHERE
        peso > (SELECT 
                AVG(peso)
            FROM
                Lote);

CREATE OR REPLACE VIEW vw_telefones_cooperativas AS
    SELECT 
        coop.razaoSocial, tel.numero
    FROM
        Cooperativa coop
            JOIN
        Telefone tel ON coop.CNPJ = tel.Cooperativa_CNPJ;

CREATE OR REPLACE VIEW vw_solicitacoes_por_safra AS
    SELECT 
        DATE_FORMAT(sa.ano, '%d/%m/%Y') AS SafraAno,
        COUNT(s.idSolicitacao) AS TotalSolicitacoes
    FROM
        Safra sa
            JOIN
        Solicitacao s ON s.Safra_idSafra = sa.idSafra
    GROUP BY sa.ano
    ORDER BY sa.ano;

CREATE OR REPLACE VIEW vw_cooperativas_sem_telefone AS
    SELECT 
        coop.CNPJ, coop.razaoSocial
    FROM
        Cooperativa coop
    WHERE
        NOT EXISTS( SELECT 
                1
            FROM
                Telefone tel
            WHERE
                tel.Cooperativa_CNPJ = coop.CNPJ);

CREATE OR REPLACE VIEW vw_lotes_completos AS
    SELECT 
        l.idLote,
        a.nome AS Armazem,
        g.nome AS Gestor,
        l.peso,
        DATE_FORMAT(l.dataEntrada, '%d/%m/%Y') AS DataEntrada
    FROM
        Lote l
            JOIN
        Armazem a ON l.Armazem_idArmazem = a.idArmazem
            JOIN
        Gestor g ON a.Gestor_CPF = g.CPF
            JOIN
        TipoSemente ts ON l.TipoSemente_idTipoSemente = ts.idTipoSemente
    ORDER BY l.dataEntrada ASC;

CREATE OR REPLACE VIEW vw_solicitacoes_pendentes AS
    SELECT 
        coop.razaoSocial, COUNT(s.idSolicitacao) AS Pendentes
    FROM
        Cooperativa coop
            JOIN
        Solicitacao s ON coop.CNPJ = s.Cooperativa_CNPJ
            JOIN
        Status st ON s.Status_idStatus = st.idStatus
    WHERE
        st.nome = 'Pendente'
    GROUP BY coop.CNPJ;
