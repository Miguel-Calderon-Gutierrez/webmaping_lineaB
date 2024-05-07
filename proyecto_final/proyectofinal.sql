--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

-- Started on 2024-04-24 13:34:17

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 26065)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 5797 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- TOC entry 364 (class 1255 OID 27185)
-- Name: registrar_visita(character varying, character varying, character varying, character varying, double precision[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.registrar_visita(cedula_visita character varying, nombre_visitante character varying, nombre_drogueria character varying, tipo_geom character varying, coordenadas double precision[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    punto GEOMETRY;
BEGIN
    -- Convertir coordenadas a tipo GEOMETRY
    punto := ST_SetSRID(ST_MakePoint(coordenadas[1], coordenadas[2]), 4326);

    -- Verificar si el visitante existe
    IF EXISTS (SELECT 1 FROM Visitante WHERE cedula = cedula_visita) THEN
        -- Actualizar el nombre del visitante
        UPDATE Visitante SET nombrevisitante = nombre_visitante WHERE cedula = cedula_visita;
    ELSE
        -- Insertar nuevo visitante
        INSERT INTO Visitante (cedula, nombrevisitante) VALUES (cedula_visita, nombre_visitante);
    END IF;

    -- Registrar la visita en DrogueriasVisitadas
    INSERT INTO DrogueriasVisitadas (fkcedulavisitante, nombreDrogueria, geom) 
    VALUES (cedula_visita, nombre_drogueria, punto);
END;
$$;


ALTER FUNCTION public.registrar_visita(cedula_visita character varying, nombre_visitante character varying, nombre_drogueria character varying, tipo_geom character varying, coordenadas double precision[]) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 225 (class 1259 OID 27177)
-- Name: drogueriasvisitadas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drogueriasvisitadas (
    id integer NOT NULL,
    fkcedulavisitante character varying(50),
    nombredrogueria character varying(150),
    geom public.geometry(Point,4326)
);


ALTER TABLE public.drogueriasvisitadas OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 27171)
-- Name: visitante; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.visitante (
    cedula character varying(50) NOT NULL,
    nombrevisitante character varying(150)
);


ALTER TABLE public.visitante OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 27186)
-- Name: cantidad_droguerias_distintas_visitadas; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.cantidad_droguerias_distintas_visitadas AS
 SELECT v.cedula,
    v.nombrevisitante,
    count(DISTINCT dv.nombredrogueria) AS cantidad_droguerias_distintas_visitadas
   FROM (public.visitante v
     JOIN public.drogueriasvisitadas dv ON (((v.cedula)::text = (dv.fkcedulavisitante)::text)))
  GROUP BY v.cedula, v.nombrevisitante
  ORDER BY v.cedula;


ALTER VIEW public.cantidad_droguerias_distintas_visitadas OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 27149)
-- Name: drogueriasflorencia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drogueriasflorencia (
    gid integer NOT NULL,
    id double precision,
    name character varying(254),
    cor_y numeric,
    cor_x numeric,
    adress character varying(254),
    number character varying(254),
    hoursatent character varying(254),
    lenguages character varying(254),
    photo character varying(254),
    geom public.geometry(Point,4326)
);


ALTER TABLE public.drogueriasflorencia OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 27148)
-- Name: drogueriasflorencia_gid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.drogueriasflorencia_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drogueriasflorencia_gid_seq OWNER TO postgres;

--
-- TOC entry 5798 (class 0 OID 0)
-- Dependencies: 221
-- Name: drogueriasflorencia_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.drogueriasflorencia_gid_seq OWNED BY public.drogueriasflorencia.gid;


--
-- TOC entry 224 (class 1259 OID 27176)
-- Name: drogueriasvisitadas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.drogueriasvisitadas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drogueriasvisitadas_id_seq OWNER TO postgres;

--
-- TOC entry 5799 (class 0 OID 0)
-- Dependencies: 224
-- Name: drogueriasvisitadas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.drogueriasvisitadas_id_seq OWNED BY public.drogueriasvisitadas.id;


--
-- TOC entry 5626 (class 2604 OID 27152)
-- Name: drogueriasflorencia gid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drogueriasflorencia ALTER COLUMN gid SET DEFAULT nextval('public.drogueriasflorencia_gid_seq'::regclass);


--
-- TOC entry 5627 (class 2604 OID 27180)
-- Name: drogueriasvisitadas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drogueriasvisitadas ALTER COLUMN id SET DEFAULT nextval('public.drogueriasvisitadas_id_seq'::regclass);


--
-- TOC entry 5788 (class 0 OID 27149)
-- Dependencies: 222
-- Data for Name: drogueriasflorencia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drogueriasflorencia (gid, id, name, cor_y, cor_x, adress, number, hoursatent, lenguages, photo, geom) FROM stdin;
1	1	DROGAS DILMAR	1.618506600000000	-75.609106400000002	CALLE 18 #8-67 7 AGOSTO	+57 44351112	"Thursday: 8â¯AMâ7:30â¯PM\r\nFriday: 8â¯AMâ7:30â¯PM\r\nSaturday: 8â¯AMâ7:30â¯PM\r\nSunday: 8â¯AMâ6â¯PM\r\nMonday: 8â¯AMâ7:30â¯PM\r\nTuesday: 8â¯AMâ7:30â¯PM\r\nWednesday: 8â¯AMâ7:30â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000032F26899FBE652C030C3352D67E5F93F
2	2	DROGUERIA COSMEDIC FLORENCIA	1.624406200000000	-75.605819499999996	calle 22 A # 3	+57 314 4496755	"Thursday: 8â¯AMâ9:30â¯PM\r\nFriday: 8â¯AMâ9:30â¯PM\r\nSaturday: 8â¯AMâ9:30â¯PM\r\nSunday: 9â¯AMâ1â¯PM\r\nMonday: 8â¯AMâ9:30â¯PM\r\nTuesday: 8â¯AMâ9:30â¯PM\r\nWednesday: 8â¯AMâ9:30â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000DCF126BFC5E652C0D3B6065B91FDF93F
3	3	DROGUERIA COSMEDIC FLORENCIA	1.620995500000000	-75.609289399999994	Cl. 21 #4c -132	+57 314 4496755	"Thursday: 9â¯AMâ11â¯PM\r\nFriday: 8â¯AMâ11:30â¯PM\r\nSaturday: 9â¯AMâ11â¯PM\r\nSunday: 5â11â¯PM\r\nMonday: 8â¯AMâ11â¯PM\r\nTuesday: 8â¯AMâ11â¯PM\r\nWednesday: 8â¯AMâ11:30â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000002AB3F798FEE652C0236937FA98EFF93F
4	4	DROGUERIA SAMMY SALUD Y VIDA	1.619479900000000	-75.631357600000001	Cra. 30 #24-30	+57 318 3797320	"Thursday: Open 24 hours\r\nFriday: 8â¯AMâ6â¯PM\r\nSaturday: 6â11â¯PM\r\nSunday: Open 24 hours\r\nMonday: Open 24 hours\r\nTuesday: Open 24 hours\r\nWednesday: Open 24 hours"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000003005B52968E852C0387870C163E9F93F
5	5	DROGUERÃA SELECTA 2	1.616080800000000	-75.613962900000004	Cra. 12 #15-84 Esquina	+57 84356254	"Thursday: 7:30â¯AMâ6â¯PM\r\nFriday: 7:30â¯AMâ6â¯PM\r\nSaturday: 7:30â¯AMâ6â¯PM\r\nSunday: 7:30â¯AMâ6â¯PM\r\nMonday: 7:30â¯AMâ6â¯PM\r\nTuesday: 7:30â¯AMâ6â¯PM\r\nWednesday: 7:30â¯AMâ6â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000451D0C2B4BE752C0A5187B8A77DBF93F
6	6	Drogueria Esmar	1.620779400000000	-75.610264099999995	Cra. 7 #21-04	+57 321 9321029	"Thursday: 7â¯AMâ9â¯PM\r\nFriday: 7â¯AMâ9â¯PM\r\nSaturday: 8â¯AMâ9â¯PM\r\nSunday: 8â¯AMâ1:30â¯PM\r\nMonday: 7â¯AMâ9â¯PM\r\nTuesday: 7â¯AMâ9â¯PM\r\nWednesday: 7â¯AMâ9â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000010DB27910EE752C0F07C5061B6EEF93F
7	7	Drogueria Florencia	1.621009300000000	-75.609350599999999	Dg. 20	+57 4342454	"Thursday: 7â¯AMâ10â¯PM\r\nFriday: 7â¯AMâ10â¯PM\r\nSaturday: 7â¯AMâ9â¯PM\r\nSunday: 7â¯AMâ8:30â¯PM\r\nMonday: 7â¯AMâ10â¯PM\r\nTuesday: 7â¯AMâ10â¯PM\r\nWednesday: 7â¯AMâ10â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000012B3A899FFE652C08D30A072A7EFF93F
8	8	Drogueria Moderna	1.618256000000000	-75.614802900000001	#12-1 a	No aplica	"Thursday: 8â¯AMâ6â¯PM\r\nFriday: 8â¯AMâ6â¯PM\r\nSaturday: 8â¯AMâ6â¯PM\r\nSunday: 8â¯AMâ6â¯PM\r\nMonday: 8â¯AMâ6â¯PM\r\nTuesday: 8â¯AMâ6â¯PM\r\nWednesday: 8â¯AMâ6â¯PM"	English	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000001A3F43EE58E752C075E4486760E4F93F
9	9	Drogueria Nakeyi	1.607047900000000	-75.601718599999998	Cl. 3 #12-2 a 12-72	+57 314 2972560	"Thursday: 7â¯AMâ11â¯PM\r\nFriday: 7â¯AMâ11â¯PM\r\nSaturday: 7â¯AMâ11â¯PM\r\nSunday: 7â¯AMâ11â¯PM\r\nMonday: 7â¯AMâ11â¯PM\r\nTuesday: 7â¯AMâ11â¯PM\r\nWednesday: 7â¯AMâ11â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000004619BB8E82E652C00AB0D9DB77B6F93F
10	10	Drogueria Servisalud Florencia	1.599541500000000	-75.596934200000007	Cl. 4 Sur	+57 318 6101781	"Thursday: Open 24 hours\r\nFriday: Open 24 hours\r\nSaturday: Open 24 hours\r\nSunday: Open 24 hours\r\nMonday: Open 24 hours\r\nTuesday: Open 24 hours\r\nWednesday: Open 24 hours"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000004BB7802B34E652C03C84F1D3B897F93F
11	11	Drogueria Servisalud Florencia	1.611301800000000	-75.603181800000002	a 6b-47	+57 322 2827295	"Thursday: Open 24 hours\r\nFriday: Open 24 hours\r\nSaturday: Open 24 hours\r\nSunday: Open 24 hours\r\nMonday: Open 24 hours\r\nTuesday: Open 24 hours\r\nWednesday: Open 24 hours"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000B722D6879AE652C061C66F65E4C7F93F
12	12	Drogueria Villafarma	1.614840800000000	-75.615286900000001	Cl. 15 #13 - 84	+57 4354783	"Thursday: 7:30â¯AMâ9â¯PM\r\nFriday: 7:30â¯AMâ9â¯PM\r\nSaturday: 7:30â¯AMâ9â¯PM\r\nSunday: 7:30â¯AMâ7â¯PM\r\nMonday: 12â¯AMâ9â¯PM\r\nTuesday: 7:30â¯AMâ9â¯PM\r\nWednesday: 7:30â¯AMâ9â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000104A4EDC60E752C092F1834E63D6F93F
13	13	Droguerias Farma-Ya	1.625187000000000	-75.604554699999994	calle 22 #2abis 02	+57 320 3411556	"Thursday: Open 24 hours\r\nFriday: Open 24 hours\r\nSaturday: Open 24 hours\r\nSunday: Open 24 hours\r\nMonday: Open 24 hours\r\nTuesday: Open 24 hours\r\nWednesday: Open 24 hours"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000028493206B1E652C04E266E15C400FA3F
14	14	Droguerias unirebaja	1.615502000000000	-75.608409199999997	Cl. 13 #6 - 05	+57 305 3968677	"Thursday: 6:30â¯AMâ10â¯PM\r\nFriday: 6:30â¯AMâ10â¯PM\r\nSaturday: 6:30â¯AMâ10â¯PM\r\nSunday: 9â¯AMâ8â¯PM\r\nMonday: 6:30â¯AMâ10â¯PM\r\nTuesday: 6:30â¯AMâ10â¯PM\r\nWednesday: 6:30â¯AMâ10â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000007925242DF0E652C023F609A018D9F93F
15	15	DroguerÃ­a El portal de la Gloria	1.615385800000000	-75.604236400000005	cra. 30 #26-26	+57 321 2953636	"Thursday: Open 24 hours\r\nFriday: Open 24 hours\r\nSaturday: Open 24 hours\r\nSunday: Open 24 hours\r\nMonday: Open 24 hours\r\nTuesday: Open 24 hours\r\nWednesday: Open 24 hours"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000614326CFABE652C0C7C3D6C79ED8F93F
16	16	DroguerÃ­a L&F	1.620661100000000	-75.632052799999997	cra. 30 #26-26	+57 313 3302826	"Thursday: 8â¯AMâ8â¯PM\r\nFriday: 8â¯AMâ8â¯PM\r\nSaturday: 9â¯AMâ8â¯PM\r\nSunday: Closed\r\nMonday: 8â¯AMâ8â¯PM\r\nTuesday: 8â¯AMâ8â¯PM\r\nWednesday: 8â¯AMâ8â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000001856968D73E852C0E26366553AEEF93F
17	17	DroguerÃ­a Pablo Sexto	1.619256300000000	-75.602306400000003	Cl. 13b #4-39	+57 321 4742863	"Thursday: 8â¯AMâ5â¯PM\r\nFriday: 8â¯AMâ5â¯PM\r\nSaturday: 8â¯AMâ5â¯PM\r\nSunday: 9â¯AMâ1â¯PM\r\nMonday: 8â¯AMâ5â¯PM\r\nTuesday: 8â¯AMâ5â¯PM\r\nWednesday: 8â¯AMâ5â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000FA8A24308CE652C0B078454B79E8F93F
18	18	DroguerÃ­a San Jorge	1.614645700000000	-75.616005999999999	Cl. 15 #14-54	+57 84362290	"Thursday: 7:30â¯AMâ7â¯PM\r\nFriday: 7:30â¯AMâ7â¯PM\r\nSaturday: 8â¯AMâ5â¯PM\r\nSunday: Closed\r\nMonday: 7:30â¯AMâ7â¯PM\r\nTuesday: 7:30â¯AMâ7â¯PM\r\nWednesday: 7:30â¯AMâ7â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000F2086EA46CE752C04E08C2BA96D5F93F
19	19	SuDrogueria La Decima	1.617552800000000	-75.612539900000002	Cl. 17 #10-2 a 10-124	No aplica	"Thursday: 8â¯AMâ9:45â¯PM\r\nFriday: 8â¯AMâ9:45â¯PM\r\nSaturday: 8â¯AMâ9:45â¯PM\r\nSunday: 4â10â¯PM\r\nMonday: 8â¯AMâ9:45â¯PM\r\nTuesday: 8â¯AMâ9:45â¯PM\r\nWednesday: 8â¯AMâ9:45â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000B07F8DDA33E752C006DA780B7FE1F93F
20	20	drogueria FERMARY	1.620110200000000	-75.596967000000006	calle 9 # 2b-93	+57 312 3698142	"Thursday: 7â¯AMâ10â¯PM\r\nFriday: 7â¯AMâ10â¯PM\r\nSaturday: 7â¯AMâ10â¯PM\r\nSunday: 8â¯AMâ10â¯PM\r\nMonday: 7â¯AMâ10â¯PM\r\nTuesday: 7â¯AMâ10â¯PM\r\nWednesday: 7â¯AMâ10â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000A47213B534E652C004A84EACF8EBF93F
21	21	CentroDrogas	1.616157200000000	-75.614833300000001	Cra. 13 #16 02	+57 313 4526797	"Thursday: 6:30â¯AMâ7:30â¯PM\r\nFriday: 6:30â¯AMâ7:30â¯PM\r\nSaturday: 6:30â¯AMâ7:30â¯PM\r\nSunday: 7â¯AMâ2â¯AM\r\nMonday: 6:30â¯AMâ7:30â¯PM\r\nTuesday: 6:30â¯AMâ7:30â¯PM\r\nWednesday: 6:30â¯AMâ7:30â¯PM"	English	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000079FFC46D59E752C0701EF3A6C7DBF93F
22	22	DROGAS CAROL	1.602833600000000	-75.601002300000005	Cra. 15a #2c-2	+57 314 8635640	"Thursday: 8â¯AMâ9â¯PM\r\nFriday: 8â¯AMâ9â¯PM\r\nSaturday: 8â¯AMâ9â¯PM\r\nSunday: 8â¯AMâ12â¯AM\r\nMonday: 8â¯AMâ9â¯PM\r\nTuesday: 8â¯AMâ9â¯PM\r\nWednesday: 8â¯AMâ9â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000088D459D276E652C00FE14ED834A5F93F
23	23	DROGUERIA EL SOL FLORENCIA	1.610361900000000	-75.598882799999998	Cl. 2c #7-64	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000C308861854E652C03C97F3D60AC4F93F
24	24	DROGUERIA FARMACAQ	1.620304100000000	-75.616051799999994	Barrio La Consolata	+57 322 6935904	"Thursday: 8â¯AMâ9â¯PM\r\nFriday: 8â¯AMâ9â¯PM\r\nSaturday: 8â¯AMâ9â¯PM\r\nSunday: 8â¯AMâ9â¯PM\r\nMonday: 8â¯AMâ9â¯PM\r\nTuesday: 8â¯AMâ9â¯PM\r\nWednesday: 8â¯AMâ9â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000156987646DE752C00732F1FDC3ECF93F
25	25	DROGUERIA FARMAPLUS FP	1.629629300000000	-75.604620900000000	EL ROSAL	+57 311 5500394	"Thursday: 7â¯AMâ11:30â¯PM\r\nFriday: 7â¯AMâ11:30â¯PM\r\nSaturday: 7â¯AMâ11:30â¯PM\r\nSunday: 7â¯AMâ11:30â¯PM\r\nMonday: 7â¯AMâ11:30â¯PM\r\nTuesday: 7â¯AMâ11:30â¯PM\r\nWednesday: 7â¯AMâ11:30â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000099FEDB1BB2E652C06AA7412CF612FA3F
26	26	DROGUERIA YAPURA	1.599330100000000	-75.603083400000003	Florencia, CaquetÃ¡	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000ACF01DEB98E652C07222B028DB96F93F
27	27	DROGUERÃA SELECTA 1	1.615285100000000	-75.613881000000006	Cl. 15 #12-06 Esquina	+57 84352494	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000B1A888D349E752C01A75633035D8F93F
28	28	Deposito Drogas Del Sur	1.617314300000000	-75.613920899999997	Calle 17 No. 11-46	+57 84351222	"Thursday: 7:30â¯AMâ6â¯PM\r\nFriday: 7:30â¯AMâ6â¯PM\r\nSaturday: 7:30â¯AMâ6â¯PM\r\nSunday: Closed\r\nMonday: 7:30â¯AMâ6â¯PM\r\nTuesday: 7:30â¯AMâ6â¯PM\r\nWednesday: 7:30â¯AMâ6â¯PM"	English	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000002DF5E27A4AE752C06FA69DF584E0F93F
29	29	Distrimedicals DroguerÃ­a	1.613994100000000	-75.616315000000000	Cra. 15 #14-15	+57 321 3517266	"Thursday: 7:30â¯AMâ7â¯PM\r\nFriday: 7:30â¯AMâ7â¯PM\r\nSaturday: 7:30â¯AMâ1â¯PM\r\nSunday: Closed\r\nMonday: 7:30â¯AMâ7â¯PM\r\nTuesday: 7:30â¯AMâ7â¯PM\r\nWednesday: 7:30â¯AMâ7â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000314278B471E752C0C3FD367AEBD2F93F
30	30	Drogueria Farmacentro	1.618271000000000	-75.613568900000004	Cra. 11 #18-15	No aplica	"Thursday: 8â¯AMâ6â¯PM\r\nFriday: 8â¯AMâ6â¯PM\r\nSaturday: 8â¯AMâ6â¯PM\r\nSunday: Closed\r\nMonday: 8â¯AMâ6â¯PM\r\nTuesday: 8â¯AMâ6â¯PM\r\nWednesday: 8â¯AMâ6â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000EFD57DB644E752C0200BD12170E4F93F
31	31	Drogueria Inyectologia	1.616018000000000	-75.609184799999994	Cra. 6	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000194E3EE2FCE652C00EF5BBB035DBF93F
32	32	Drogueria San Angel DJ	1.622355500000000	-75.606604300000001	Calle 20 No 1b 43	+57 321 4826299	"Thursday: 7â9:30â¯AM\r\nFriday: 7â9:30â¯AM\r\nSaturday: 7â9:30â¯AM\r\nSunday: 7â9:30â¯AM\r\nMonday: 7â9:30â¯AM\r\nTuesday: 7â9:30â¯AM\r\nWednesday: 7â9:30â¯AM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000003B87D79AD2E652C08BC56F0A2BF5F93F
33	33	Drogueria San Gabriel	1.603947500000000	-75.595618599999995	Florencia, CaquetÃ¡	No aplica	"Thursday: 7:30â¯AMâ7:30â¯PM\r\nFriday: 7:30â¯AMâ7:30â¯PM\r\nSaturday: 7:30â¯AMâ7:30â¯PM\r\nSunday: Closed\r\nMonday: 7:30â¯AMâ7:30â¯PM\r\nTuesday: 7:30â¯AMâ7:30â¯PM\r\nWednesday: 7:30â¯AMâ7:30â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000EAF8799D1EE652C0EF0390DAC4A9F93F
34	34	DroguerÃ­a MEDICOR Florencia	1.605704100000000	-75.602683900000002	Cra. 14	+57 310 3460695	"Thursday: 7â¯AMâ11â¯PM\r\nFriday: 7â¯AMâ11â¯PM\r\nSaturday: 7â¯AMâ11â¯PM\r\nSunday: 7â¯AMâ11â¯PM\r\nMonday: 7â¯AMâ11â¯PM\r\nTuesday: 7â¯AMâ11â¯PM\r\nWednesday: 7â¯AMâ11â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000D9147E5F92E652C08ED948C8F6B0F93F
36	36	DroguerÃ­a Pro y Farmas	1.608564700000000	-75.597754899999998	180001	+57 312 5774806	"Thursday: 7:30â¯AMâ7:30â¯PM\r\nFriday: 7:30â¯AMâ7:30â¯PM\r\nSaturday: 7:30â¯AMâ7:30â¯PM\r\nSunday: Closed\r\nMonday: 7:30â¯AMâ7:30â¯PM\r\nTuesday: 7:30â¯AMâ7:30â¯PM\r\nWednesday: 7:30â¯AMâ7:30â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000085A1C49D41E652C03600C056AEBCF93F
37	37	DroguerÃ­a SÃºper Descuento	1.620918200000000	-75.609684799999997	Cl. 21 #5-20	No aplica	"Thursday: 7â¯AMâ12â¯PM\r\nFriday: 7â¯AMâ12â¯PM\r\nSaturday: 7â¯AMâ12â¯PM\r\nSunday: 7â¯AMâ12â¯PM\r\nMonday: 7â¯AMâ12â¯PM\r\nTuesday: 7â¯AMâ12â¯PM\r\nWednesday: 7â¯AMâ12â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000009237651305E752C0E7DB27EC47EFF93F
38	38	LA REBAJA PLUS NO. 1 - FLORENCIA	1.615454700000000	-75.613229500000003	Cl. 15 # 11-14	+57 608 4347699	"Thursday: 7â¯AMâ10:30â¯PM\r\nFriday: 7â¯AMâ10:30â¯PM\r\nSaturday: 8â¯AMâ10:30â¯PM\r\nSunday: 8â¯AMâ10â¯PM\r\nMonday: 7â¯AMâ10:30â¯PM\r\nTuesday: 7â¯AMâ10:30â¯PM\r\nWednesday: 7â¯AMâ10:30â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000051DCF1263FE752C03CB60A07E7D8F93F
39	39	OPTIFARMA DROGUERÃAS	1.617138800000000	-75.613632999999993	Florencia, CaquetÃ¡	+57 313 2082397	"Thursday: 7â¯AMâ7â¯PM\r\nFriday: 7â¯AMâ7â¯PM\r\nSaturday: 7â¯AMâ7â¯PM\r\nSunday: 7â¯AMâ1â¯PM\r\nMonday: 7â¯AMâ7â¯PM\r\nTuesday: 7â¯AMâ7â¯PM\r\nWednesday: 7â¯AMâ7â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000C4AF58C345E752C0A37B31EFCCDFF93F
40	40	Super Drogas Las Avenidas	1.609483500000000	-75.605907200000004	Car 11 N 5B 14	+57 312 3077141	"Thursday: 7â¯AMâ8:30â¯PM\r\nFriday: 7â¯AMâ8:30â¯PM\r\nSaturday: 7â¯AMâ8:30â¯PM\r\nSunday: 7:30â¯AMâ8:30â¯PM\r\nMonday: 7â¯AMâ8:30â¯PM\r\nTuesday: 7â¯AMâ8:30â¯PM\r\nWednesday: 7â¯AMâ8:30â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000004D1AFE2EC7E652C0D2393FC571C0F93F
41	41	BIODROGAS DroguerÃ­a Minimarket	1.619952400000000	-75.615877999999995	Cl. 21 #12-51	+57 315 2887720	"Thursday: 8â¯AMâ10â¯PM\r\nFriday: 8â¯AMâ10â¯PM\r\nSaturday: 8â¯AMâ10â¯PM\r\nSunday: Closed\r\nMonday: 8â¯AMâ10â¯PM\r\nTuesday: 8â¯AMâ10â¯PM\r\nWednesday: 8â¯AMâ10â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000DB148F8B6AE752C0353A313553EBF93F
42	42	DROGUERIA COMFACA	1.612531400000000	-75.611835900000003	a 10-131,	+57 84366300	"Thursday: 8â¯AMâ8â¯PM\r\nFriday: 8â¯AMâ8â¯PM\r\nSaturday: 8â¯AMâ8â¯PM\r\nSunday: 8â¯AMâ12â¯PM\r\nMonday: 8â¯AMâ8â¯PM\r\nTuesday: 8â¯AMâ8â¯PM\r\nWednesday: 8â¯AMâ8â¯PM"	English	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000003341C35128E752C0985EACB9EDCCF93F
43	43	DROGUERÃA Salud Vital(no es la EPS)	1.626333900000000	-75.603402599999995	Calle 22 1C 42-46 4375227	+57 4375227	"Thursday: 7â¯AMâ11â¯PM\r\nFriday: 7â¯AMâ11â¯PM\r\nSaturday: 7â¯AMâ11â¯PM\r\nSunday: 8:30â10â¯AM\r\nMonday: 7â¯AMâ11â¯PM\r\nTuesday: 7â¯AMâ11â¯PM\r\nWednesday: 7â¯AMâ11â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000009154F0259EE652C0A6040EB27605FA3F
44	44	Drogas Condor	1.616933100000000	-75.614227799999995	a 16-108,	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000D1521E824FE752C04D1E053EF5DEF93F
45	45	Drogas Del Parque	1.613614100000000	-75.614490200000006	Cl. 13	+57 84342533	\N	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000009A2DB4CE53E752C0E2D4BD045DD1F93F
46	46	Drogas mateo	1.615385800000000	-75.604236400000005	Carrera 14B	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000614326CFABE652C0C7C3D6C79ED8F93F
47	47	Droguerias Cruz Verde - C.C. Gran Plaza Florencia	1.624476400000000	-75.606065799999996	Centro Comercial Gran Plaza	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000578E35C8C9E652C025FB31F7DAFDF93F
48	48	DroguerÃ­a Colsubsidio	1.611292500000000	-75.607710100000006	Cra. 9 #7 - 75	+57 322 8839091	"Thursday: 7â¯AMâ6â¯PM\r\nFriday: 7â¯AMâ6â¯PM\r\nSaturday: 7â¯AMâ6â¯PM\r\nSunday: Closed\r\nMonday: 7â¯AMâ6â¯PM\r\nTuesday: 7â¯AMâ6â¯PM\r\nWednesday: 7â¯AMâ6â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000BB3CE7B8E4E652C02BA4FCA4DAC7F93F
49	49	DroguerÃ­a JARG	1.628034800000000	-75.597355300000004	Cra. 1 Bis #16-3	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000E865B9113BE652C098FFEB376E0CFA3F
50	50	DroguerÃ­a Medicor Florencia II	1.607433900000000	-75.601805499999998	Jorge Eliecer Gaitan	+57 311 5423867	"Thursday: 7â¯AMâ11â¯PM\r\nFriday: 7â¯AMâ11â¯PM\r\nSaturday: 7â¯AMâ11â¯PM\r\nSunday: 9â¯AMâ11â¯PM\r\nMonday: 7â¯AMâ11â¯PM\r\nTuesday: 7â¯AMâ11â¯PM\r\nWednesday: 7â¯AMâ11â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000634337FB83E652C02FB5EF9B0CB8F93F
51	51	DroguerÃ­a y variedades la victoria	1.619920000000000	-75.616135999999997	Cl. 21 #13 07	+57 320 3443629	\N	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000D978B0C56EE752C05E2EE23B31EBF93F
52	52	Drugs Economia	1.615833800000000	-75.613147100000006	Cra. 11 #15-51	+57 84342113	"Thursday: 7:30â¯AMâ7â¯PM\r\nFriday: 8â¯AMâ6:30â¯PM\r\nSaturday: 8â¯AMâ6:30â¯PM\r\nSunday: 8â¯AMâ12â¯PM\r\nMonday: 8â¯AMâ6:30â¯PM\r\nTuesday: 8â¯AMâ6:30â¯PM\r\nWednesday: 8â¯AMâ6:30â¯PM"	English	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000C98855CD3DE752C0AD57EC8A74DAF93F
53	53	FARMASALUD DROGUERIA	1.605722700000000	-75.602414800000005	Calle 3 N. 14-02 B/ Versalles - rosal	+57 310 7646025	"Thursday: Open 24 hours\r\nFriday: Open 24 hours\r\nSaturday: Open 24 hours\r\nSunday: Closed\r\nMonday: Open 24 hours\r\nTuesday: Open 24 hours\r\nWednesday: Open 24 hours"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000001728CEF68DE652C0FB1D2F490AB1F93F
54	54	Farmacenter La 14 Florencia	1.615682000000000	-75.615712000000002	Cra. 14 #Cll 14	+57 84341666	"Thursday: 7â¯AMâ9â¯PM\r\nFriday: 7â¯AMâ9â¯PM\r\nSaturday: 7â¯AMâ9â¯PM\r\nSunday: 8â¯AMâ1â¯PM\r\nMonday: 7â¯AMâ9â¯PM\r\nTuesday: 7â¯AMâ9â¯PM\r\nWednesday: 7â¯AMâ9â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000004EF04DD367E752C022C66B5ED5D9F93F
55	55	Farmacia DroguerÃ­a Moderna	1.633644400000000	-75.606499600000006	Florencia, CaquetÃ¡	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000060C2B2E3D0E652C05AB2744F6823FA3F
56	56	LA REBAJA NO. 1 - FLORENCIA	1.616848600000000	-75.615022699999997	Esquina	+57 608 4357501	"Thursday: 6:30â¯AMâ7:30â¯PM\r\nFriday: 6:30â¯AMâ7:30â¯PM\r\nSaturday: 6:30â¯AMâ7:30â¯PM\r\nSunday: 7â¯AMâ6â¯PM\r\nMonday: 6:30â¯AMâ7:30â¯PM\r\nTuesday: 6:30â¯AMâ7:30â¯PM\r\nWednesday: 6:30â¯AMâ7:30â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000000CB32B885CE752C08C5539A39CDEF93F
57	57	LA REBAJA NO. 3 - FLORENCIA	1.616220700000000	-75.613259299999996	Cl 16 #11 - 01	+57 608 4356095	"Thursday: 7â¯AMâ9:30â¯PM\r\nFriday: 7â¯AMâ9:30â¯PM\r\nSaturday: 7â¯AMâ9:30â¯PM\r\nSunday: 8â¯AMâ8â¯PM\r\nMonday: 7â¯AMâ9:30â¯PM\r\nTuesday: 7â¯AMâ9:30â¯PM\r\nWednesday: 7â¯AMâ9:30â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000F15DEFA33FE752C042E4993C0ADCF93F
58	58	LA REBAJA NO. 6 - FLORENCIA	1.614587500000000	-75.612890899999996	Cl. 14 #11 - 11	+57 608 4356708	"Thursday: 7â¯AMâ9â¯PM\r\nFriday: 7â¯AMâ9â¯PM\r\nSaturday: 7â¯AMâ9â¯PM\r\nSunday: 8â¯AMâ7â¯PM\r\nMonday: 7â¯AMâ9â¯PM\r\nTuesday: 7â¯AMâ9â¯PM\r\nWednesday: 7â¯AMâ9â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000006E1C09A39E752C0857CD0B359D5F93F
59	59	Mi Farmacia Plus - Farmacenter	1.610878400000000	-75.606224400000002	Cl. 6 #9B - 05 Esquina	+57 608 4380288	"Thursday: 8â¯AMâ8â¯PM\r\nFriday: 8â¯AMâ8â¯PM\r\nSaturday: 8â¯AMâ8â¯PM\r\nSunday: 9â¯AMâ2â¯PM\r\nMonday: 8â¯AMâ8â¯PM\r\nTuesday: 8â¯AMâ8â¯PM\r\nWednesday: 8â¯AMâ8â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000062026D61CCE652C02D53DD6D28C6F93F
60	60	drogueria san mateo	1.614685000000000	-75.616082300000002	Cl. 15 #14-58	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000003F8974E46DE752C0D97745F0BFD5F93F
61	61	DROGUERÃA LA POPULAR	1.627379100000000	-75.638929500000003	Cl. 37A #38- 04	No aplica	"Thursday: 8â¯AMâ9â¯PM\r\nFriday: 8â¯AMâ9â¯PM\r\nSaturday: 8â¯AMâ9â¯PM\r\nSunday: 12â8â¯PM\r\nMonday: 8â¯AMâ9â¯PM\r\nTuesday: 8â¯AMâ9â¯PM\r\nWednesday: 8â¯AMâ9â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000C7BC8E38E4E852C0451ACBAABE09FA3F
62	62	Discount Drugs	1.617213700000000	-75.610897499999993	Esquina	+57 608 4347222	"Thursday: 7â¯AMâ9â¯PM\r\nFriday: 7â¯AMâ9â¯PM\r\nSaturday: 7â¯AMâ9â¯PM\r\nSunday: 8â¯AMâ7â¯PM\r\nMonday: 7â¯AMâ9â¯PM\r\nTuesday: 7â¯AMâ9â¯PM\r\nWednesday: 7â¯AMâ9â¯PM"	English	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000052EDD3F118E752C05D4A02791BE0F93F
63	63	Drogas La Consolata	1.620537900000000	-75.614633799999993	Cra. 10	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000000981012956E752C036DB2626B9EDF93F
64	64	Drogas Plus	1.614943900000000	-75.608324800000005	Cl. 12	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000215624CBEEE652C0C0FE356ACFD6F93F
65	65	Drogas Vitafarma	1.613926600000000	-75.606842900000004	Cra. 5b	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000D4539A83D6E652C0C44FD2B2A4D2F93F
66	66	Drogas el Caguan	1.617247800000000	-75.615315499999994	Cra. 13 #17-67	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000334E435461E752C07A72A83A3FE0F93F
67	67	Drogueria Bellavista	1.599372700000000	-75.602170299999997	Cra. 22 #2c - 38	No aplica	"Thursday: 7â10â¯AM\r\nFriday: 7â¯AMâ10â¯PM\r\nSaturday: 8â¯AMâ9:30â¯PM\r\nSunday: 2:30â9:30â¯PM\r\nMonday: 7â¯AMâ10â¯PM\r\nTuesday: 7â¯AMâ10â¯PM\r\nWednesday: 7â¯AMâ10â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000D7474CF589E652C0F0D709D40797F93F
68	68	Drogueria Biosalud	1.627309600000000	-75.639103899999995	Florencia, CaquetÃ¡	No aplica	"Thursday: 8:30â¯AMâ8â¯PM\r\nFriday: 8:30â¯AMâ8â¯PM\r\nSaturday: 8:30â¯AMâ8â¯PM\r\nSunday: Closed\r\nMonday: 8:30â¯AMâ8â¯PM\r\nTuesday: 8:30â¯AMâ8â¯PM\r\nWednesday: 8:30â¯AMâ8â¯PM"	English	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000BF4F0B14E7E852C02F7887CA7509FA3F
69	69	Drogueria de la Cruz Roja	1.614684000000000	-75.614565600000006	Cra. 13 #141 a 14-99	No aplica	"Thursday: 8â¯AMâ6â¯PM\r\nFriday: 8â¯AMâ6â¯PM\r\nSaturday: 8â¯AMâ5â¯PM\r\nSunday: Closed\r\nMonday: 8â¯AMâ6â¯PM\r\nTuesday: 8â¯AMâ6â¯PM\r\nWednesday: 8â¯AMâ6â¯PM"	English	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000C94FF40A55E752C0CEFDD5E3BED5F93F
70	70	Droguerias Cruz Verde - Acolsure	1.620748900000000	-75.622305600000004	Cl 26	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000008807DEDAD3E752C09572086696EEF93F
71	71	DroguerÃ¬a Super Salud V&Y	1.614541500000000	-75.604739300000006	Florencia, CaquetÃ¡	+57 322 3815534	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000C806770CB4E652C07A8EC87729D5F93F
72	72	DroguerÃ­a Carol	1.599412100000000	-75.598784300000005	a 19-57	No aplica	No aplica	English	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000EE76627B52E652C0163A65243197F93F
73	73	DroguerÃ­a Super Descuento D.A.B	1.614775700000000	-75.604746899999995	Cl. 6Âª	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000DF76572CB4E652C014025E0B1FD6F93F
74	74	DroguerÃ­a la sÃºper rebaja	1.625750700000000	-75.590354800000000	Cra. 14 Este #9	No aplica	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000058C27F5FC8E552C08B2F7F2A1303FA3F
75	75	Famarcias Cruz Verde	1.613945700000000	-75.616217100000000	Cra. 15 #14 - 17	+57 1 800 0999991	"Thursday: 8â¯AMâ6â¯PM\r\nFriday: 8â¯AMâ6â¯PM\r\nSaturday: 9â¯AMâ12â¯PM\r\nSunday: Closed\r\nMonday: 8â¯AMâ6â¯PM\r\nTuesday: 8â¯AMâ6â¯PM\r\nWednesday: 8â¯AMâ6â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000001AEFD81970E752C03651F0B9B8D2F93F
76	76	Farmacenter Mateo	1.603705000000000	-75.601664000000000	Cra. 15 #2B-62	+57 84358959	"Thursday: 7â¯AMâ10â¯PM\r\nFriday: 7â¯AMâ10â¯PM\r\nSaturday: 7â¯AMâ10â¯PM\r\nSunday: 8â¯AMâ12â¯PM\r\nMonday: 7â¯AMâ10â¯PM\r\nTuesday: 7â¯AMâ10â¯PM\r\nWednesday: 7â¯AMâ10â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000008ECBB8A981E652C029E8F692C6A8F93F
77	77	Farmacia Surtimedica	1.612380900000000	-75.610862299999994	barrio cooperativa Calle 10 N.9-74 Barrio cooperativa	+57 310 8178970	"Thursday: 8â¯AMâ6â¯PM\r\nFriday: 8â¯AMâ6â¯PM\r\nSaturday: 8â¯AMâ1â¯PM\r\nSunday: Closed\r\nMonday: 8â¯AMâ6â¯PM\r\nTuesday: 8â¯AMâ6â¯PM\r\nWednesday: 8â¯AMâ6â¯PM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000FF36305E18E752C0E91E23EA4FCCF93F
78	78	Mr Matius Farmacia	1.607585200000000	-75.608166600000004	Cl. 6 #15-32	+57 313 3928936	"Thursday: Open 24 hours\r\nFriday: Open 24 hours\r\nSaturday: Open 24 hours\r\nSunday: Open 24 hours\r\nMonday: Open 24 hours\r\nTuesday: Open 24 hours\r\nWednesday: Open 24 hours"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000040619A33ECE652C0B4893842ABB8F93F
79	79	Servidrogas Florencia	1.617146300000000	-75.605130200000005	Tv. 6 #14a26	+57 310 2467575	"Thursday: Open 24 hours\r\nFriday: Open 24 hours\r\nSaturday: Open 24 hours\r\nSunday: Open 24 hours\r\nMonday: Open 24 hours\r\nTuesday: Open 24 hours\r\nWednesday: Open 24 hours"	English	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000009BB40474BAE652C0F88E75CCD4DFF93F
80	80	Servidrogas Florencia YPC	1.607529200000000	-75.601973799999996	Cra. 11 #3-30	+57 4347269	"Thursday: 7â¯AMâ12â¯AM\r\nFriday: Open 24 hours\r\nSaturday: Open 24 hours\r\nSunday: 7â¯AMâ12â¯AM\r\nMonday: 7â¯AMâ12â¯AM\r\nTuesday: 7â¯AMâ12â¯AM\r\nWednesday: 7â¯AMâ12â¯AM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E610000020031EBD86E652C038D7D58970B8F93F
81	81	Colsubsidio Dispensario	1.607544400000000	-75.608194100000006	a 15a-118, Cl. 6 #15a2	+57 84362962	"Thursday: 9â¯AMâ7â¯AM\r\nFriday: 9â¯AMâ7â¯AM\r\nSaturday: 9â¯AMâ12â¯PM\r\nSunday: Closed\r\nMonday: 9â¯AMâ7â¯AM\r\nTuesday: 9â¯AMâ7â¯AM\r\nWednesday: 9â¯AMâ7â¯AM"	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000B147F2A6ECE652C018E30D7A80B8F93F
82	82	Drogueria Farmasalud WEF	1.625039300000000	-75.634234399999997	Av. Ciudadela Siglo XXI	+57 312 5896908	No aplica	English	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000E27FE14B97E852C08C6F83352900FA3F
83	83	DroguerÃ­a luz	1.627432400000000	-75.636067499999996	Unnamed Road	+57 311 4412920	No aplica	Spanish	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E61000001AA37554B5E852C07036678EF609FA3F
84	84	H & V Deposito de Drogas	1.618387300000000	-75.616020199999994	Cl. 19 #13 - 41	No aplica	"Thursday: 7:30â¯AMâ6â¯AM\r\nFriday: 7:30â¯AMâ6â¯AM\r\nSaturday: 8:30â¯AMâ1â¯AM\r\nSunday: Closed\r\nMonday: 7:30â¯AMâ6â¯AM\r\nTuesday: 7:30â¯AMâ6â¯AM\r\nWednesday: 7:30â¯AMâ6â¯AM"	English	https://www.portafolio.co/files/article_main/uploads/2020/03/03/5e5ee10c24d25.jpeg	0101000020E6100000392BFDDF6CE752C01730DC14EAE4F93F
85	85	Rebaja plus 2 - Cambio	1.623938000000000	-75.605115400000003	Cra. 3 #21-35 a 21-1	No aplica	No aplica	Spanish	https://www.kienyke.com/sites/default/files/styles/amp_1200x675_16_9/public/2022-11/Drogas%20La%20Rebaja%20.jpg?itok=-mxEYY2c	0101000020E61000009553F135BAE652C0D5B48B69A6FBF93F
35	35	Drogueria Toledo	1.625540200000000	-75.602839900000006	Cl. 20 #2-05	No aplica	"Thursday: 8â¯AMâ10â¯PM\r\nFriday: 8â¯AMâ10â¯PM\r\nSaturday: 8â¯AMâ11â¯PM\r\nSunday: 8â¯AMâ10â¯PM\r\nMonday: 8â¯AMâ10â¯PM\r\nTuesday: 8â¯AMâ10â¯PM\r\nWednesday: 8â¯AMâ10â¯PM"	Spanish	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR3bUgW0WaKqqfc-FS5Xy6ktnnUCZECyauBWiMe2GGnVg&s	0101000020E610000055CECDED94E652C03255D5703602FA3F
\.


--
-- TOC entry 5791 (class 0 OID 27177)
-- Dependencies: 225
-- Data for Name: drogueriasvisitadas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.drogueriasvisitadas (id, fkcedulavisitante, nombredrogueria, geom) FROM stdin;
25	123456	Drogueria Toledo	0101000020E610000055CECDED94E652C03255D5703602FA3F
26	123456	Drogueria San Angel DJ	0101000020E61000003B87D79AD2E652C08BC56F0A2BF5F93F
27	987654	Farmacia DroguerÃ­a Moderna	0101000020E610000060C2B2E3D0E652C05AB2744F6823FA3F
28	987654	Drogueria Servisalud Florencia	0101000020E6100000B722D6879AE652C061C66F65E4C7F93F
29	123456	Drogas el Caguan	0101000020E6100000334E435461E752C07A72A83A3FE0F93F
30	123456	Drogueria Villafarma	0101000020E6100000104A4EDC60E752C092F1834E63D6F93F
31	987654	Drogueria Servisalud Florencia	0101000020E61000004BB7802B34E652C03C84F1D3B897F93F
32	7777	Rebaja plus 2 - Cambio	0101000020E61000009553F135BAE652C0D5B48B69A6FBF93F
33	7777	Drogueria Toledo	0101000020E610000055CECDED94E652C03255D5703602FA3F
34	987654	Drogueria Servisalud Florencia	0101000020E61000004BB7802B34E652C03C84F1D3B897F93F
35	987654	DROGUERIA SAMMY SALUD Y VIDA	0101000020E61000003005B52968E852C0387870C163E9F93F
36	1010	Drogas Del Parque	0101000020E61000009A2DB4CE53E752C0E2D4BD045DD1F93F
37	1010	Colsubsidio Dispensario	0101000020E6100000B147F2A6ECE652C018E30D7A80B8F93F
38	2020	Drogas Del Parque	0101000020E61000009A2DB4CE53E752C0E2D4BD045DD1F93F
\.


--
-- TOC entry 5625 (class 0 OID 26383)
-- Dependencies: 217
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- TOC entry 5789 (class 0 OID 27171)
-- Dependencies: 223
-- Data for Name: visitante; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.visitante (cedula, nombrevisitante) FROM stdin;
123456	Miguel A Calderon G
7777	Helen Vargas
987654	Alejandro Toledo
1010	Luis C
2020	Profe sig
\.


--
-- TOC entry 5800 (class 0 OID 0)
-- Dependencies: 221
-- Name: drogueriasflorencia_gid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drogueriasflorencia_gid_seq', 85, true);


--
-- TOC entry 5801 (class 0 OID 0)
-- Dependencies: 224
-- Name: drogueriasvisitadas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.drogueriasvisitadas_id_seq', 38, true);


--
-- TOC entry 5633 (class 2606 OID 27156)
-- Name: drogueriasflorencia drogueriasflorencia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drogueriasflorencia
    ADD CONSTRAINT drogueriasflorencia_pkey PRIMARY KEY (gid);


--
-- TOC entry 5637 (class 2606 OID 27184)
-- Name: drogueriasvisitadas drogueriasvisitadas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drogueriasvisitadas
    ADD CONSTRAINT drogueriasvisitadas_pkey PRIMARY KEY (id);


--
-- TOC entry 5635 (class 2606 OID 27175)
-- Name: visitante visitante_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visitante
    ADD CONSTRAINT visitante_pkey PRIMARY KEY (cedula);


--
-- TOC entry 5631 (class 1259 OID 27157)
-- Name: drogueriasflorencia_geom_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX drogueriasflorencia_geom_idx ON public.drogueriasflorencia USING gist (geom);


-- Completed on 2024-04-24 13:34:21

--
-- PostgreSQL database dump complete
--

