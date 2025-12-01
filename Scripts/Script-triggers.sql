-- Impedir cadastro de Lote onde a data de vencimento é menor que a data de entrada  OK
DELIMITER $$

CREATE TRIGGER tg_before_insert_update_lote
BEFORE INSERT ON Lote
FOR EACH ROW
BEGIN
    IF NEW.dataVencimento < NEW.dataEntrada THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Data de vencimento não pode ser menor que a data de entrada.';
    END IF;
END$$

DELIMITER ;



-- Impedir solicitação quando a quantidade é menor ou igual a zero  OK
DELIMITER $$

CREATE TRIGGER tg_before_insert_solicitacao
BEFORE INSERT ON Solicitacao
FOR EACH ROW
BEGIN
    IF NEW.quantidade <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Não é possível fazer uma solicitação com quantidade negativa.';
    END IF;
END$$

DELIMITER ;

-- Ao criar uma nova solicitação atualiza o status dela deve ser pendente  OK
DELIMITER $$

CREATE  TRIGGER tg_before_insert_solicitacao_status
BEFORE INSERT ON Solicitacao
FOR EACH ROW
BEGIN
    DECLARE idStatusInicial INT;

    -- Buscar o ID correspondente a 'Pendente' (seu status inicial)
    SELECT idStatus INTO idStatusInicial
    FROM Status
    WHERE nome = 'Pendente' -- Usando 'Pendente' conforme seu INSERT
    LIMIT 1;

    -- Define automaticamente o ID do Status no novo registro de Solicitacao
    IF idStatusInicial IS NOT NULL THEN
        SET NEW.Status_idStatus = idStatusInicial;
    ELSE
        -- Opcional: Levanta um erro se o status inicial não for encontrado
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Status inicial (Pendente) não encontrado na tabela Status.';
    END IF;
END$$

DELIMITER ;



-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Impedir que a soma das quantidades de tipos de sementes ultrapasse o total solicitado  OK
DELIMITER $$

CREATE TRIGGER tg_before_insert_solicitacaotpsemente
BEFORE INSERT ON SolicitacaoTipoSemente
FOR EACH ROW
BEGIN
    DECLARE total_permitido INT;
    DECLARE soma_atual INT;

    SELECT quantidade 
    INTO total_permitido
    FROM Solicitacao 
    WHERE idSolicitacao = NEW.Solicitacao_idSolicitacao;

    SELECT IFNULL(SUM(quantidade), 0)
    INTO soma_atual
    FROM SolicitacaoTipoSemente
    WHERE Solicitacao_idSolicitacao = NEW.Solicitacao_idSolicitacao;

    IF (soma_atual + NEW.quantidade) > total_permitido THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A soma das quantidades de tipos de sementes ultrapassa o total solicitado.';
    END IF;
END$$

DELIMITER ;


-- --------------------------------------------------------------------------------------------------------

-- Impedir Alteração de CPF ou Usuário do Gestor  	OK

DELIMITER $$

CREATE TRIGGER tg_before_update_gestor_id_imovel
BEFORE UPDATE ON Gestor
FOR EACH ROW
BEGIN
    -- 1. Impedir alteração do CPF (Chave Primária e Identificador Principal)
    IF OLD.CPF != NEW.CPF THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é permitido alterar o CPF do Gestor após o cadastro.';
    END IF;

    -- 2. Impedir alteração do nome de usuário (Identificador de Login)
    IF OLD.usuario != NEW.usuario THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é permitido alterar o nome de usuário (login) do Gestor.';
    END IF;


END$$

DELIMITER ;

-- --------------------------------------------------------------------------------------------------------
-- Impedir insert de lote com peso zero ou negativo  OK
DELIMITER $$

CREATE TRIGGER tg_before_insert_lote_peso
BEFORE INSERT ON Lote
FOR EACH ROW
BEGIN
    IF NEW.peso <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'O peso do lote deve ser um valor positivo.';
    END IF;
END$$

DELIMITER ;


-- ----------------------------------------------------------------------------------------------------------

--            --------------------------       ------------------------------------
 -- trigger para garantir email e usuario unico  OK
DELIMITER $$

CREATE  TRIGGER tg_before_insert_operador_unicidade
BEFORE INSERT ON OperadorArmazem
FOR EACH ROW
BEGIN
    -- 1. Verificar Unicidade do E-mail (Somente no INSERT, pois NEW.idOperadorArmazem será NULL)
    IF EXISTS (
        SELECT 1 FROM OperadorArmazem
        WHERE email = NEW.email
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Este endereço de e-mail já está cadastrado para outro Operador de Armazém.';
    END IF;

    -- 2. Verificar Unicidade do Nome de Usuário (Somente no INSERT)
    IF EXISTS (
        SELECT 1 FROM OperadorArmazem
        WHERE usuario = NEW.usuario
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Este nome de usuário (login) já está em uso.';
    END IF;
END$$

DELIMITER ;




--  

-- ---------------------------------------------------------- --------------------- 
-- trigger para garantir que não troque para um email que ja está em uso  OK
DELIMITER $$

CREATE TRIGGER tg_before_update_operador_unicidade
BEFORE UPDATE ON OperadorArmazem
FOR EACH ROW
BEGIN
    -- 1. Verificar Unicidade do E-mail (apenas se o e-mail foi alterado)
    IF OLD.email != NEW.email AND EXISTS (
        SELECT 1 FROM OperadorArmazem
        WHERE email = NEW.email
        AND idOperadorArmazem <> OLD.idOperadorArmazem -- Exclui o próprio registro
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Este endereço de e-mail já está cadastrado para outro Operador de Armazém.';
    END IF;

    -- 2. Verificar Unicidade do Nome de Usuário (apenas se o usuário foi alterado)
    IF OLD.usuario != NEW.usuario AND EXISTS (
        SELECT 1 FROM OperadorArmazem
        WHERE usuario = NEW.usuario
        AND idOperadorArmazem <> OLD.idOperadorArmazem -- Exclui o próprio registro
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Este nome de usuário (login) já está em uso.';
    END IF;
END$$

DELIMITER ;



-- ---------------------------------------------------------
-- Impedir Exclusão de Gestor com Armazéns Ativos  OK
DELIMITER $$

CREATE TRIGGER tg_before_delete_gestor
BEFORE DELETE ON Gestor
FOR EACH ROW
BEGIN
    DECLARE count_armazens INT;

    -- Conta os Armazéns gerenciados por este Gestor
    SELECT COUNT(*) INTO count_armazens
    FROM Armazem
    WHERE Gestor_CPF = OLD.CPF;

    -- Se houver armazéns, impede a exclusão
    IF count_armazens > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível excluir o Gestor pois ele gerencia armazéns ativos.';
    END IF;
END$$

DELIMITER ;



-- ---------------------------------------------------------------------
-- Impedir Exclusão de Cooperativa com Solicitações Pendentes/Ativas  OK
DELIMITER $$

CREATE TRIGGER tg_before_delete_cooperativa
BEFORE DELETE ON Cooperativa
FOR EACH ROW
BEGIN
    DECLARE count_solicitacoes_ativas INT;
    DECLARE status_pendente_aprovado VARCHAR(100);

    -- Lista de status ativos/em análise (assumindo ID 1='Pendente', 2='Aprovada')
    SELECT GROUP_CONCAT(idStatus) INTO status_pendente_aprovado FROM `status`
    WHERE nome IN ('Pendente', 'Aprovada');
    
    -- Conta solicitações da cooperativa com status ativo
    SELECT COUNT(*) INTO count_solicitacoes_ativas
    FROM Solicitacao
    WHERE Cooperativa_CNPJ = OLD.CNPJ
      AND FIND_IN_SET(Status_idStatus, status_pendente_aprovado) > 0;

    IF count_solicitacoes_ativas > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível excluir a Cooperativa pois ela possui solicitações pendentes ou aprovadas.';
    END IF;
END$$

DELIMITER ;



-- ------------------------------------------------------------------
-- Impedir Exclusão de Safra com Solicitações Vinculadas     OK
DELIMITER $$

CREATE TRIGGER tg_before_delete_safra
BEFORE DELETE ON Safra
FOR EACH ROW
BEGIN
    DECLARE count_solicitacoes INT;

    -- Conta o número de solicitações vinculadas a esta Safra
    SELECT COUNT(*) INTO count_solicitacoes
    FROM Solicitacao
    WHERE Safra_idSafra = OLD.idSafra;

    IF count_solicitacoes > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível excluir a Safra pois existem solicitações registradas para ela.';
    END IF;
END$$

DELIMITER ;



-- -----------------------------------------------------------------
-- Impedir Cadastro de Telefone Duplicado  OK
DELIMITER $$

CREATE TRIGGER tg_before_insert_update_telefone_duplicado
BEFORE INSERT ON Telefone
FOR EACH ROW
BEGIN
    -- Verifica duplicidade para Gestor
    IF NEW.Gestor_CPF IS NOT NULL AND EXISTS (
        SELECT 1 FROM Telefone
        WHERE Gestor_CPF = NEW.Gestor_CPF AND numero = NEW.numero
          AND idTelefone <> IFNULL(NEW.idTelefone, 0)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Este número de telefone já está cadastrado para este Gestor.';
    END IF;

    -- Verifica duplicidade para Cooperativa
    IF NEW.Cooperativa_CNPJ IS NOT NULL AND EXISTS (
        SELECT 1 FROM Telefone
        WHERE Cooperativa_CNPJ = NEW.Cooperativa_CNPJ AND numero = NEW.numero
          AND idTelefone != IFNULL(NEW.idTelefone, 0)
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Este número de telefone já está cadastrado para esta Cooperativa.';
    END IF;
END$$

DELIMITER ;

