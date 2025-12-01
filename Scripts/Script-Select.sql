-- 1 Listar todos os armazéns com seus gestores

select arm.nome as armazem, g.nome as gestor
	from Armazem arm
		join Gestor g on arm.gestor_CPF = g.cpf;
        
-- 2 Listar cooperativas com seus endereços completos

select c.RazaoSocial, e.Cidade, e.Bairro, e.Numero
	from Cooperativa c	
		join Endereco e on c.Endereco_idEndereco = e.idEndereco;
        
-- 3 Listar lotes com tipo de semente e armazém

select l.idLote, ts.nome as Tipo, arm.nome as Armazem
	from Lote l
		join TipoSemente ts on l.TipoSemente_idTipoSemente = ts.idTipoSemente
        join Armazem arm on l.Armazem_idArmazem = arm.idArmazem;
        
-- 4 Quantidade de lotes por armazém

select arm.nome as Armazem, count(l.idLote) as Total_Lotes
	from Armazem arm
		left join Lote l on l.Armazem_idArmazem = arm.idArmazem
        group by arm.idArmazem;
        
-- 5 Cooperativas que mais solicitaram sementes

select coop.RazaoSocial "Razão Social",
 count(s.idSolicitacao) as Total_Solicitacoes
	from Solicitacao s
		join Cooperativa coop on s.Cooperativa_CNPJ = coop.CNPJ
	group by coop.CNPJ
    order by total_solicitacoes desc;
    
-- 6 Listar solicitações e o status atual

select s.idSolicitacao "Id Solicitação", st.nome as Status
	from Solicitacao s
		join Status st on s.Status_idStatus = st.idStatus;
        
-- 7 Solicitações de um tipo específico de semente

select coop.RazaoSocial "Razão Social", ts.nome as Tipo, sts.Quantidade
	from SolicitacaoTipoSemente sts
		join TipoSemente ts on sts.TipoSemente_idTipoSemente = ts.idTipoSemente
        join Solicitacao s on sts.Solicitacao_idSolicitacao = s.idSolicitacao
        join Cooperativa coop on s.Cooperativa_CNPJ = coop.CNPJ;
        
-- 8 Listar gestores com telefones cadastrados

select g.Nome, tel.Numero
	from Gestor g
		join Telefone tel on tel.Gestor_CPF = g.CPF;
        
-- 9 Listar operadores e os armazéns que operam

select ope.nome as Operador, arm.nome as Armazem
	from OperadorArmazem ope 
		join Armazem arm on ope.idOperadorArmazem = arm.OperadorArmazem_idOperadorArmazem;
        
-- 10 Peso total de sementes por tipo

select ts.nome as Tipo, sum(l.peso) as Peso_Total
	from Lote l 
		join TipoSemente ts on l.TipoSemente_idTipoSemente = ts.idTipoSemente
	group by ts.idTipoSemente;
		
-- 11 Lotes que vencem em menos de 60 dias

select idLote, 
date_format(DataVencimento, '%d/%m/%Y') "Data Vencimento"
	from Lote
		Where datediff(dataVencimento, curdate()) < 60;
        
-- 12 Quantidade de cooperativas por cidade

select e.Cidade, count(coop.CNPJ) "Total Cooperativas"
	from Cooperativa coop
		join Endereco e on coop.Endereco_idEndereco = e.idEndereco
	group by e.cidade;
    
-- 13 Solicitações aprovadas

select s.idSolicitacao "Id Solicitação",
coop.razaoSocial "Razão Social"
	from Solicitacao s 
		join Cooperativa coop on s.Cooperativa_CNPJ = coop.CNPJ
	where s.Status_idStatus = (
		select idStatus from Status where nome = 'Aprovada'
        );
        
   -- 14 Cooperativas com mais de um telefone
   
   select coop.razaoSocial "Razão Social",
   count(tel.idTelefone) "Quatidade de Telefones"
	from Cooperativa coop	
		join Telefone tel on coop.CNPJ = tel.Cooperativa_CNPJ
	group by coop.CNPJ
		having count(tel.idTelefone) > 1;
        
-- 15 Lotes acima da média de peso

select idLote "Id Lote",
peso "Peso"
	from Lote
where peso > (select avg(peso) from Lote);

-- 16 Telefones das cooperativas

select coop.razaoSocial "Razão Social",
tel.numero "Número"
	from Cooperativa coop 
		join Telefone tel on coop.CNPJ = tel.Cooperativa_CNPJ;
        
-- 17 Total de solicitações por safra

select 
date_format(sa.ano, '%d/%m/%Y') "Safra/Ano", 
count(s.idSolicitacao) "Total de Solicitações"
	from Safra sa
		join Solicitacao s on s.Safra_idSafra = sa.idSafra
	group by sa.ano
	order by sa.ano;
    
-- 18 Cooperativas sem telefone cadastrado

select coop.CNPJ,
coop.razaoSocial "Razão Social"
	from Cooperativa coop 
where not exists (
	select 1
    from Telefone tel
    where tel.Cooperativa_CNPJ = coop.CNPJ
    );
    
-- 19 Lotes com informações completas: Armazém, Gestor e tipo de semente

select
	l.idLote "Id Lote",
    a.nome "Armazém",
    g.nome "Gestor",
    l.peso "Peso",
    date_format(l.dataEntrada,  '%d/%m/%Y') "Data Entrada"
		from Lote l 
			join Armazem a on l.Armazem_idArmazem = a.idArmazem
            join Gestor g on a.Gestor_CPF = g.CPF
            join TipoSemente ts on l.TipoSemente_idTipoSemente = ts.idTipoSemente
		order by l.dataEntrada asc;
    
-- 20 Cooperativas e o total de solicitações pendentes

select coop.razaoSocial "Razão Social",
count(s.idSolicitacao) "Pendentes"
	from Cooperativa coop 
		join Solicitacao s on coop.CNPJ = s.Cooperativa_CNPJ
        join Status st on s.Status_idStatus = st.idStatus
	where st.nome = 'Pendente'
    group by coop.CNPJ;