USE [uade-server]
GO
/****** Object:  Table [dbo].[borrar]    Script Date: 1/4/2024 16:18:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  Table [dbo].[clientes]    Script Date: 1/4/2024 16:18:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[clientes](
	[cliente_num] [int] NOT NULL,
	[nombre] [varchar](15) NOT NULL,
	[apellido] [varchar](15) NOT NULL,
	[empresa] [varchar](20) NULL,
	[domicilio] [varchar](20) NULL,
	[ciudad] [varchar](25) NULL,
	[provincia_cod] [char](2) NULL,
	[codPostal] [char](5) NULL,
	[telefono] [varchar](18) NULL,
	[cliente_ref] [int] NULL,
	[estado] [char](1) NULL,
PRIMARY KEY CLUSTERED
(
	[cliente_num] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fabricantes]    Script Date: 1/4/2024 16:18:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fabricantes](
	[fabricante_cod] [varchar](5) NOT NULL,
	[fabricante_nom] [varchar](20) NOT NULL,
	[tiempo_entrega] [smallint] NULL,
	[provincia_cod] [char](2) NULL,
PRIMARY KEY CLUSTERED
(
	[fabricante_cod] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[facturas]    Script Date: 1/4/2024 16:18:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[facturas](
	[factura_num] [int] NOT NULL,
	[cliente_num] [int] NULL,
	[fecha_emision] [date] NOT NULL,
	[fecha_vto] [date] NULL,
	[fecha_pago] [datetime] NULL,
PRIMARY KEY CLUSTERED
(
	[factura_num] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[facturas_det]    Script Date: 1/4/2024 16:18:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[facturas_det](
	[factura_num] [int] NOT NULL,
	[renglon] [smallint] NOT NULL,
	[producto_cod] [smallint] NOT NULL,
	[cantidad] [smallint] NOT NULL,
	[precio_unit] [decimal](10, 2) NOT NULL,
PRIMARY KEY CLUSTERED
(
	[factura_num] ASC,
	[renglon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[productos]    Script Date: 1/4/2024 16:18:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[productos](
	[producto_cod] [smallint] NOT NULL,
	[producto_desc] [varchar](30) NOT NULL,
	[fabricante_cod] [varchar](5) NULL,
	[precio_unit] [decimal](10, 2) NULL,
PRIMARY KEY CLUSTERED
(
	[producto_cod] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[provincias]    Script Date: 1/4/2024 16:18:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[provincias](
	[provincia_cod] [char](2) NOT NULL,
	[provincia_desc] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED
(
	[provincia_cod] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[productos] ADD  DEFAULT ((0)) FOR [precio_unit]
GO
ALTER TABLE [dbo].[clientes]  WITH CHECK ADD FOREIGN KEY([cliente_ref])
REFERENCES [dbo].[clientes] ([cliente_num])
GO
ALTER TABLE [dbo].[clientes]  WITH CHECK ADD FOREIGN KEY([provincia_cod])
REFERENCES [dbo].[provincias] ([provincia_cod])
GO
ALTER TABLE [dbo].[fabricantes]  WITH CHECK ADD FOREIGN KEY([provincia_cod])
REFERENCES [dbo].[provincias] ([provincia_cod])
GO
ALTER TABLE [dbo].[facturas]  WITH CHECK ADD FOREIGN KEY([cliente_num])
REFERENCES [dbo].[clientes] ([cliente_num])
GO
ALTER TABLE [dbo].[facturas]  WITH CHECK ADD FOREIGN KEY([cliente_num])
REFERENCES [dbo].[clientes] ([cliente_num])
GO
ALTER TABLE [dbo].[facturas_det]  WITH CHECK ADD FOREIGN KEY([factura_num])
REFERENCES [dbo].[facturas] ([factura_num])
GO
ALTER TABLE [dbo].[facturas_det]  WITH CHECK ADD FOREIGN KEY([producto_cod])
REFERENCES [dbo].[productos] ([producto_cod])
GO
ALTER TABLE [dbo].[productos]  WITH CHECK ADD FOREIGN KEY([fabricante_cod])
REFERENCES [dbo].[fabricantes] ([fabricante_cod])
GO
