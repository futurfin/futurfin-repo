USE [master]
GO

/****** Object:  Database [DB-futurfin]    Script Date: 12/8/2019 1:06:19 PM ******/
CREATE DATABASE [DB-futurfin]
 CONTAINMENT = NONE
 ON  PRIMARY 
 ;

 USE [DB-futurfin]
GO
/****** Object:  Table [dbo].[transaction]    Script Date: 12/8/2019 1:08:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[transaction](
	[transaction_sid] [int] IDENTITY(1,1) NOT NULL,
	[account_cd] [varchar](30) NOT NULL,
	[operation_date] [date] NOT NULL,
	[value_date] [date] NOT NULL,
	[transaction_descr] [varchar](255) NOT NULL,
	[transaction_full_descr] [varchar](255) NOT NULL,
	[amt] [money] NOT NULL,
	[transaction_type_cd] [varchar](30) NOT NULL,
	[transaction_hash]  AS (checksum([value_date],[amt]))
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[transaction_v]    Script Date: 12/8/2019 1:08:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[transaction_v]
as

SELECT [transaction_sid]
      ,[account_cd]
      ,[operation_date]
      ,[value_date]
      ,[transaction_descr]

      ,replace(
	   replace(
	   replace(
	   replace( cast(checksum([transaction_full_descr]) as varchar(255)) , '0',' '), '1',' i'), '2',' r'), '3',' b')
	  
				as [transaction_full_descr]
      ,[amt]* (1+checksum([value_date],[operation_date])%9) as [amt]
      ,[transaction_type_cd]
      ,[transaction_hash]
  FROM [dbo].[transaction]
GO
/****** Object:  Table [dbo].[account]    Script Date: 12/8/2019 1:08:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[account](
	[account_cd] [varchar](30) NOT NULL,
	[account_descr] [varchar](255) NOT NULL,
 CONSTRAINT [PK_account] PRIMARY KEY CLUSTERED 
(
	[account_cd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tran001]    Script Date: 12/8/2019 1:08:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tran001](
	[Data Operazione] [datetime] NULL,
	[Data Valuta] [datetime] NULL,
	[Entrate] [float] NULL,
	[Uscite] [float] NULL,
	[Descrizione] [varchar](max) NULL,
	[Descrizione Completa] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[transaction_category]    Script Date: 12/8/2019 1:08:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[transaction_category](
	[transaction_category_cd] [varchar](30) NOT NULL,
	[transaction_category_descr] [varchar](255) NULL,
 CONSTRAINT [PK_transaction_category] PRIMARY KEY CLUSTERED 
(
	[transaction_category_cd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[transaction_category_map]    Script Date: 12/8/2019 1:08:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[transaction_category_map](
	[transaction_category_cd] [varchar](30) NOT NULL,
	[transaction_sid] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[transaction_type]    Script Date: 12/8/2019 1:08:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[transaction_type](
	[transaction_type_cd] [varchar](30) NOT NULL,
	[transaction_type_descr] [varchar](255) NULL,
 CONSTRAINT [PK_transaction_type] PRIMARY KEY CLUSTERED 
(
	[transaction_type_cd] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[transaction]  WITH CHECK ADD  CONSTRAINT [FK_transaction_account] FOREIGN KEY([account_cd])
REFERENCES [dbo].[account] ([account_cd])
GO
ALTER TABLE [dbo].[transaction] CHECK CONSTRAINT [FK_transaction_account]
GO
ALTER TABLE [dbo].[transaction]  WITH CHECK ADD  CONSTRAINT [FK_transaction_transaction_type] FOREIGN KEY([transaction_type_cd])
REFERENCES [dbo].[transaction_type] ([transaction_type_cd])
GO
ALTER TABLE [dbo].[transaction] CHECK CONSTRAINT [FK_transaction_transaction_type]
GO
ALTER TABLE [dbo].[transaction_category_map]  WITH CHECK ADD  CONSTRAINT [FK_transaction_category_map_transaction] FOREIGN KEY([transaction_sid])
REFERENCES [dbo].[transaction] ([transaction_sid])
GO
ALTER TABLE [dbo].[transaction_category_map] CHECK CONSTRAINT [FK_transaction_category_map_transaction]
GO
ALTER TABLE [dbo].[transaction_category_map]  WITH CHECK ADD  CONSTRAINT [FK_transaction_category_map_transaction_category] FOREIGN KEY([transaction_category_cd])
REFERENCES [dbo].[transaction_category] ([transaction_category_cd])
GO
ALTER TABLE [dbo].[transaction_category_map] CHECK CONSTRAINT [FK_transaction_category_map_transaction_category]
GO
/****** Object:  StoredProcedure [dbo].[sp_load_transaction]    Script Date: 12/8/2019 1:08:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[sp_load_transaction]
as
delete [dbo].[transaction];

INSERT INTO [dbo].[transaction]
           ([account_cd]
           ,[operation_date]
           ,[value_date]
           ,[transaction_descr]
           ,[transaction_full_descr]
           ,[amt]
           ,[transaction_type_cd])

     SELECT
           '001'												as  account_cd
           ,cast([Data Operazione]			as date)			as operation_date
           ,cast([Data Valuta]				as date)			as value_dateas
           ,cast([Descrizione]				as varchar(255))	as transaction_descr
           ,cast([Descrizione Completa]		as varchar(255))	as transaction_full_descr

           ,cast(
			case when [Entrate] is not null then   [Entrate] 
											else - [Uscite] 
			end
			as money)											as amt
		   
           ,case when [Entrate] is not null then 'CRE' else 'DEB' end 
																as transaction_type_cd
	FROM
		[dbo].[tran001]


GO
/****** Object:  StoredProcedure [dbo].[sp_load_transaction_001]    Script Date: 12/8/2019 1:08:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[sp_load_transaction_001]
as
delete [dbo].[transaction];

INSERT INTO [dbo].[transaction]
           ([account_cd]
           ,[operation_date]
           ,[value_date]
           ,[transaction_descr]
           ,[transaction_full_descr]
           ,[amt]
           ,[transaction_type_cd])

     SELECT
           '001'												as  account_cd
           ,cast([Data Operazione]			as date)			as operation_date
           ,cast([Data Valuta]				as date)			as value_dateas
           ,cast([Descrizione]				as varchar(255))	as transaction_descr
           ,cast([Descrizione Completa]		as varchar(255))	as transaction_full_descr

           ,cast(
			case when [Entrate] is not null then   [Entrate] 
											else - [Uscite] 
			end
			as money)											as amt
		   
           ,case when [Entrate] is not null then 'CRE' else 'DEB' end 
																as transaction_type_cd
	FROM
		[dbo].[tran001]


GO


