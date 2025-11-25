-- Procedure para cadastro de gestor e telefone
delimiter $$
create procedure cadGestor_telefone(
    IN pcpf VARCHAR(14),
    IN pnome VARCHAR(60),
    IN pemail VARCHAR(80),
    IN psenha_hash VARCHAR(128),
    IN pusuario VARCHAR(20),
    
    IN ptelefone VARCHAR(15))
    begin
        INSERT INTO Gestor (CPF, nome, email, senha_hash, usuario)
			VALUES (pcpf, pnome, pemail, psenha_hash, pusuario);
            
		IF ptelefone IS NOT NULL AND ptelefone <> ''
			THEN INSERT INTO Telefone (numero, Gestor_CPF)
				VALUES (ptelefone, pcpf);
    END IF;

    end$$
delimiter;
    
-- Procedure para cadastro de cooperativa, telefone e endereço
delimiter $$

create procedure cadCooperativa_tel_endereco(
    IN pcnpj             VARCHAR(18),
    IN prazaoSocial      VARCHAR(60),
    IN pnomeResponsavel  VARCHAR(60),
    IN pcpfResponsavel   VARCHAR(14),
    IN pemailInst        VARCHAR(80),
    IN psenha_hash       VARCHAR(128),
    IN pusuario          VARCHAR(20),
    IN ptelefone         VARCHAR(15),

    IN puf               CHAR(2),
    IN pcidade           VARCHAR(45),
    IN pbairro           VARCHAR(45),
    IN prua              VARCHAR(45),
    IN pnumero           INT,
    IN pcomp             VARCHAR(45),
    IN pcep              VARCHAR(9)
)
BEGIN
    DECLARE vidEnd INT;

    
    INSERT INTO Endereco (UF, cidade, bairro, rua, numero, comp, cep)
    VALUES (puf, pcidade, pbairro, prua, pnumero, pcomp, pcep);

    
    SET vidEnd = LAST_INSERT_ID();

    
    INSERT INTO Cooperativa (
        CNPJ,
        razaoSocial,
        nomeResponsavel,
        cpfResponsavel,
        emailInstitucional,
        senha_hash,
        usuario,
        Endereco_idEndereco
    )
    VALUES (
        pcnpj,
        prazaoSocial,
        pnomeResponsavel,
        pcpfResponsavel,
        pemailInst,
        psenha_hash,
        pusuario,
        vidEnd
    );

    
    IF ptelefone IS NOT NULL AND ptelefone <> '' THEN
        INSERT INTO Telefone (numero, Cooperativa_CNPJ)
        VALUES (ptelefone, pcnpj);
    END IF;
END$$

delimiter ;

-- Procedure para cadastro de armazem e endereço
delimiter $$
create procedure cadArmazem_end(
	IN pnome 		VARCHAR(60),
    IN pdescricao 	VARCHAR(150),
    IN pgestorCPF  VARCHAR(14),
    
    IN puf 			CHAR(2),
    IN pcidade		VARCHAR(45),
    IN pbairro		VARCHAR(45),
    IN prua			VARCHAR(45),
    IN pnumero		INT,
    IN pcomp		VARCHAR(45),
	IN pcep			VARCHAR(9))
	begin
		declare vidEnd INT;
		insert into endereco (UF, cidade, bairro, rua, numero, comp, cep)
		values (puf, pcidade, pbairro, prua, pnumero, pcomp, pcer);
		
		SET vidEnd = last_insert_id();
		
		insert into armazem (nome, descricao, gestor_cpf, endereco_idEndereco)
		value(pnome, pdescricao, pgestorCPF, vidEnd);
	end $$

delimiter ;

-- Procedure para cadastrar lotes
delimiter $$
create procedure cadLote(
	IN pdataEntrada DATE,
	IN pdataVencimento DATE,
	IN ppeso INT,
	IN parmazem INT,
	IN ptipoSemente INT,
	IN pqr VARCHAR(255))
    begin
		if ppeso <= 0 then
			signal sqlstate '45000'
				set message_text = 'Erro: O peso do lote deve ser maior que zero.';
		end if;
        
        if pdataVencimento <= pdataEntrada then
			signal sqlstate '45000'
				set message_text = 'Erro: A dada de vencimento deve ser posterior à data de entrada.';
		end if;
        
        if (select count(*) from TipoSemente where idTipoSemente = ptipoSemente) = 0 then
			signal sqlstate '45000'
				set message_text = 'Erro: Tipo de semente informado não existe';
		end if;
        
        if (select count(*) from lote where qr_payload = pqr) > 0 then
			signal sqlstate '45000'
				set message_text = 'Erro: Qr code já cadastrado para outro lote.';
		end if;
        INSERT INTO Lote (dataEntrada, dataVencimento, peso, Armazem_idArmazem, TipoSemente_idTipoSemente, qr_payload)
        values (pDataEntrada, pDataVencimento, pPeso, pArmazem, pTipoSemente, pQr);
        
        
    end $$

delimiter ;

-- Função para retornar quantas solicitações aquela cooperativa já fez

delimiter $$
create function caclSolicitacaoCoop(cnpj varchar(18))
		returns INT deterministic
    begin
    declare cont int;
		SELECT 
    COUNT(*)
INTO cont FROM
    solicitacao
WHERE
    Cooperativa_CNPJ = cnpj;
        
        return cont;
    end $$
delimiter ;

-- Função para retornar os dias que faltam para vencer um lote

delimiter $$
create function caclDiasVencimento(id int)
	returns INT deterministic
	begin
		declare vVencimento DATE;
        declare vDias int;
SELECT 
    dataVencimento into vVencimento
FROM
    lote
WHERE
    idLote = id;
	SET vDias = datediff(vVencimento, CURRENT_DATE());
    return vDias;
	end $$
delimiter ;

-- Função para retornar os dias que faltam para vencer um lote

delimiter $$
create function calcLoteArmazem(arm int)
	returns int deterministic
    begin
		declare numero INT;
        SELECT COUNT(*) into numero
		FROM Lote
		WHERE Armazem_idArmazem = arm;
        return numero;
    end $$
delimiter ;


-- Retorna a soma do peso de todos os lotes dentro do armazém.

delimiter $$
create function calcTotalPeso(arm int)
	returns int deterministic
    begin
		declare pesoTotal int;
        select sum(peso) into pesoTotal
        from lote
        where Armazem_idArmazem = arm;
        return pesoTotal;
	end $$
delimiter ;

