   --   Scripts Teste triggers  --

-- Script teste para trigger (Ao criar uma nova solicitação atualiza o status dela deve ser pendente)


INSERT INTO Solicitacao (
    quantidade,
    numeroProdutoresBeneficiados,
    Cooperativa_CNPJ,
    Safra_idSafra,
    Status_idStatus 
) VALUES (
    100, 5, '12.345.678/0011', 1, 4 -- Passando 4 (Cancelada) para provar que a trigger altera para 1 (Pendente)
);
SELECT
    s.idSolicitacao,
    s.quantidade,
    c.razaoSocial AS Cooperativa,
    st.nome AS StatusAtual
FROM
    Solicitacao s
JOIN
    Cooperativa c ON s.Cooperativa_CNPJ = c.CNPJ
JOIN
    Status st ON s.Status_idStatus = st.idStatus
ORDER BY
    s.idSolicitacao DESC
LIMIT 1;




--  Script teste para trigger Impedir cadastro de Lote onde a data de vencimento é menor que a data de entrada

INSERT INTO Lote (dataEntrada, dataVencimento, peso, Armazem_idArmazem,
            TipoSemente_idTipoSemente)
 VALUES ('2026-01-01', '2025-12-31', 500, 1, 1);
 
 
 -- Script teste para trigger Impedir solicitação quando a quantidade é menor ou igual a zero
 
 INSERT INTO Solicitacao (
    quantidade,
    numeroProdutoresBeneficiados,
    Cooperativa_CNPJ,
    Safra_idSafra
) VALUES (
    0, 
    1,
    '12.345.678/0001', 
    1
);


-- Script teste  Impedir que a soma das quantidades de tipos de sementes ultrapasse o total solicitado

-- faz na ordem esse aqui um por um.
SET @idSolicitacao = 35;
INSERT INTO SolicitacaoTipoSemente (Solicitacao_idSolicitacao, TipoSemente_idTipoSemente, quantidade) 
	VALUES (@idSolicitacao, 5, 2200);
INSERT INTO SolicitacaoTipoSemente (Solicitacao_idSolicitacao, TipoSemente_idTipoSemente, quantidade) 
	VALUES (35, 8, 2301); -- Usando TipoSemente_idTipoSemente = 8 para evitar duplicidade de PK



-- Script teste Impedir Alteração de CPF ou Usuário do Gestor 


UPDATE Gestor
SET CPF = '999.999.999-99'
WHERE CPF = '001.001.001-01';



-- Script teste Impedir insert de lote com peso zero ou negativo 

INSERT INTO Lote (dataEntrada, dataVencimento, peso, Armazem_idArmazem, TipoSemente_idTipoSemente) 
	VALUES ('2026-06-01', '2026-12-31', 0, 1, 1);



-- Script teste  Para garantir email e usuario unico 

INSERT INTO OperadorArmazem (nome, email, senha_hash, usuario) 
	VALUES ('Novo Op. Teste Email', 'operador01@agro.com', 'dev_hash', 'novo_op_teste_e'); 


-- Script teste para garantir que não troque para um email que ja está em uso

-- Tenta alterar o email do Operador 02 para o e-mail do Operador 01.
-- Este UPDATE DEVE FALHAR.
UPDATE OperadorArmazem
SET email = 'operador01@agro.com'
WHERE idOperadorArmazem = 3;



-- Script teste  Impedir Exclusão de Gestor com Armazéns Ativos 

DELETE FROM Gestor WHERE CPF = '001.001.001-01';


-- Script teste Impedir Exclusão de Cooperativa com Solicitações Pendentes/Ativas


DELETE FROM Cooperativa WHERE CNPJ = '12.345.678/0001';


-- Script teste Impedir Exclusão de Safra com Solicitações Vinculadas

DELETE FROM Safra WHERE idSafra = 1;


-- Script teste Impedir Cadastro de Telefone Duplicado

INSERT INTO Telefone (numero, Gestor_CPF) 
	VALUES ('(81) 9001-0000', '001.001.001-01');

