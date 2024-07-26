-- Criação do Banco de Dados
CREATE DATABASE IF NOT EXISTS Ecommerce;
USE Ecommerce;

-- Criação das Tabelas
CREATE TABLE IF NOT EXISTS Cliente (
    idCliente INT PRIMARY KEY AUTO_INCREMENT,
    CPF VARCHAR(14) UNIQUE NOT NULL,
    endereco VARCHAR(255) NOT NULL,
    pj_ou_PF ENUM('PJ', 'PF') NOT NULL
);

CREATE TABLE IF NOT EXISTS Fornecedor (
    idFornecedor INT PRIMARY KEY AUTO_INCREMENT,
    razao_social VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS Pagamento (
    idPagamento INT PRIMARY KEY AUTO_INCREMENT,
    forma_pagamento VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS Entrega (
    idEntrega INT PRIMARY KEY AUTO_INCREMENT,
    status_entrega VARCHAR(50) NOT NULL,
    codigo_rastreio VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS Produto (
    idProduto INT PRIMARY KEY AUTO_INCREMENT,
    categoria VARCHAR(100) NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    idFornecedor INT,
    FOREIGN KEY (idFornecedor) REFERENCES Fornecedor(idFornecedor)
);

CREATE TABLE IF NOT EXISTS Estoque (
    idEstoque INT PRIMARY KEY AUTO_INCREMENT,
    local VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS Terceiro (
    idTerceiro INT PRIMARY KEY AUTO_INCREMENT,
    razao_social VARCHAR(255) NOT NULL,
    local VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS Pedido (
    idPedido INT PRIMARY KEY AUTO_INCREMENT,
    status_pedido VARCHAR(50) NOT NULL,
    descricao TEXT,
    frete DECIMAL(10, 2),
    idCliente INT,
    idEntrega INT,
    idPagamento INT,
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente),
    FOREIGN KEY (idEntrega) REFERENCES Entrega(idEntrega),
    FOREIGN KEY (idPagamento) REFERENCES Pagamento(idPagamento)
);

CREATE TABLE IF NOT EXISTS Pedido_Produto (
    idPedido INT,
    idProduto INT,
    quantidade INT NOT NULL,
    PRIMARY KEY (idPedido, idProduto),
    FOREIGN KEY (idPedido) REFERENCES Pedido(idPedido),
    FOREIGN KEY (idProduto) REFERENCES Produto(idProduto)
);

-- Tabela Estoque_Produto (associação entre Estoque e Produto)
CREATE TABLE IF NOT EXISTS Estoque_Produto (
    idEstoque INT,
    idProduto INT,
    quantidade INT NOT NULL,
    PRIMARY KEY (idEstoque, idProduto),
    FOREIGN KEY (idEstoque) REFERENCES Estoque(idEstoque),
    FOREIGN KEY (idProduto) REFERENCES Produto(idProduto)
);

-- Consultas SQL

-- Quantos pedidos foram feitos por cada cliente?
SELECT c.idCliente, COUNT(p.idPedido) AS total_pedidos
FROM Cliente c
LEFT JOIN Pedido p ON c.idCliente = p.idCliente
GROUP BY c.idCliente;

-- Algum fornecedor também é um terceiro?
SELECT f.razao_social AS fornecedor, t.razao_social AS terceiro
FROM Fornecedor f
JOIN Terceiro t ON f.razao_social = t.razao_social;

-- Relação de produtos, fornecedores e estoques:
SELECT p.descricao AS produto, f.razao_social AS fornecedor, e.local AS estoque
FROM Produto p
JOIN Fornecedor f ON p.idFornecedor = f.idFornecedor
JOIN Estoque_Produto ep ON p.idProduto = ep.idProduto
JOIN Estoque e ON ep.idEstoque = e.idEstoque;

-- Relação de nomes dos fornecedores e nomes dos produtos:
SELECT f.razao_social AS fornecedor, p.descricao AS produto
FROM Produto p
JOIN Fornecedor f ON p.idFornecedor = f.idFornecedor;

-- Pedidos com status 'Entregue' e seus respectivos códigos de rastreio:
SELECT p.idPedido, e.codigo_rastreio
FROM Pedido p
JOIN Entrega e ON p.idEntrega = e.idEntrega
WHERE e.status_entrega = 'Entregue';
