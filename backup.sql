--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2025-06-08 11:26:22

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2 (class 3079 OID 296815)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 4943 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 869 (class 1247 OID 296827)
-- Name: enum_diagnose_areas_area_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_diagnose_areas_area_type AS ENUM (
    'oyster',
    'cobia'
);


ALTER TYPE public.enum_diagnose_areas_area_type OWNER TO postgres;

--
-- TOC entry 872 (class 1247 OID 296832)
-- Name: enum_users_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_users_role AS ENUM (
    'expert',
    'manager',
    'admin'
);


ALTER TYPE public.enum_users_role OWNER TO postgres;

--
-- TOC entry 875 (class 1247 OID 296840)
-- Name: enum_users_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_users_status AS ENUM (
    'active',
    'inactive'
);


ALTER TYPE public.enum_users_status OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 296845)
-- Name: SequelizeMeta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SequelizeMeta" (
    name character varying(255) NOT NULL
);


ALTER TABLE public."SequelizeMeta" OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 296848)
-- Name: diagnose_areas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diagnose_areas (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    area double precision NOT NULL,
    area_type public.enum_diagnose_areas_area_type NOT NULL,
    province uuid,
    district uuid,
    CONSTRAINT diagnose_areas_area_type_check CHECK (((area_type)::text = ANY (ARRAY[('oyster'::character varying)::text, ('cobia'::character varying)::text])))
);


ALTER TABLE public.diagnose_areas OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 296852)
-- Name: diagnose_areas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.diagnose_areas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.diagnose_areas_id_seq OWNER TO postgres;

--
-- TOC entry 4944 (class 0 OID 0)
-- Dependencies: 220
-- Name: diagnose_areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diagnose_areas_id_seq OWNED BY public.diagnose_areas.id;


--
-- TOC entry 221 (class 1259 OID 296853)
-- Name: diagnose_naturalelements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diagnose_naturalelements (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.diagnose_naturalelements OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 296856)
-- Name: diagnose_naturalelements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.diagnose_naturalelements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.diagnose_naturalelements_id_seq OWNER TO postgres;

--
-- TOC entry 4945 (class 0 OID 0)
-- Dependencies: 222
-- Name: diagnose_naturalelements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diagnose_naturalelements_id_seq OWNED BY public.diagnose_naturalelements.id;


--
-- TOC entry 223 (class 1259 OID 296857)
-- Name: diagnose_prediction_natureelements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diagnose_prediction_natureelements (
    id integer NOT NULL,
    prediction_id integer NOT NULL,
    nature_element_id integer NOT NULL,
    value double precision NOT NULL
);


ALTER TABLE public.diagnose_prediction_natureelements OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 296860)
-- Name: diagnose_prediction_natureelements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.diagnose_prediction_natureelements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.diagnose_prediction_natureelements_id_seq OWNER TO postgres;

--
-- TOC entry 4946 (class 0 OID 0)
-- Dependencies: 224
-- Name: diagnose_prediction_natureelements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diagnose_prediction_natureelements_id_seq OWNED BY public.diagnose_prediction_natureelements.id;


--
-- TOC entry 225 (class 1259 OID 296861)
-- Name: diagnose_predictions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diagnose_predictions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    area_id integer NOT NULL,
    prediction_text text NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


ALTER TABLE public.diagnose_predictions OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 296866)
-- Name: diagnose_predictions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.diagnose_predictions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.diagnose_predictions_id_seq OWNER TO postgres;

--
-- TOC entry 4947 (class 0 OID 0)
-- Dependencies: 226
-- Name: diagnose_predictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diagnose_predictions_id_seq OWNED BY public.diagnose_predictions.id;


--
-- TOC entry 230 (class 1259 OID 296951)
-- Name: districts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.districts (
    id uuid NOT NULL,
    name character varying(100) NOT NULL,
    lat double precision,
    long double precision,
    province_id uuid
);


ALTER TABLE public.districts OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 296946)
-- Name: provinces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.provinces (
    id uuid NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.provinces OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 296882)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    role public.enum_users_role NOT NULL,
    email character varying(255) NOT NULL,
    address character varying(255),
    phone character varying(255),
    status public.enum_users_status DEFAULT 'active'::public.enum_users_status NOT NULL,
    province uuid,
    district uuid,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY (ARRAY[('end_user'::character varying)::text, ('expert'::character varying)::text, ('admin'::character varying)::text, ('manager'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 296889)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 4948 (class 0 OID 0)
-- Dependencies: 228
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4747 (class 2604 OID 296890)
-- Name: diagnose_areas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_areas ALTER COLUMN id SET DEFAULT nextval('public.diagnose_areas_id_seq'::regclass);


--
-- TOC entry 4748 (class 2604 OID 296891)
-- Name: diagnose_naturalelements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_naturalelements ALTER COLUMN id SET DEFAULT nextval('public.diagnose_naturalelements_id_seq'::regclass);


--
-- TOC entry 4749 (class 2604 OID 296892)
-- Name: diagnose_prediction_natureelements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements ALTER COLUMN id SET DEFAULT nextval('public.diagnose_prediction_natureelements_id_seq'::regclass);


--
-- TOC entry 4750 (class 2604 OID 296893)
-- Name: diagnose_predictions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions ALTER COLUMN id SET DEFAULT nextval('public.diagnose_predictions_id_seq'::regclass);


--
-- TOC entry 4751 (class 2604 OID 296895)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4925 (class 0 OID 296845)
-- Dependencies: 218
-- Data for Name: SequelizeMeta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SequelizeMeta" (name) FROM stdin;
\.


--
-- TOC entry 4926 (class 0 OID 296848)
-- Dependencies: 219
-- Data for Name: diagnose_areas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnose_areas (id, name, latitude, longitude, area, area_type, province, district) FROM stdin;
13	Bãi A	18.7651	105.7336	388	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
14	Bãi A	13.7376	109.2051	1518	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
15	Bãi 2	15.4506	108.6577	1776	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
7	Rừng ngập mặn huyện Thái Thụy	20.57005905173713	106.5977587766479	999	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
8	Bãi nuôi cá giò vịnh Cái Bèo	20.729263681499532	107.05760892842237	998	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
12	Bãi C	18.0684	106.279	1360	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
23	Bãi B	20.9684	107.0518	1810	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
29	Bãi A	20.96849545001074	107.12143857848233	1146	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
2	Bãi nuôi hàu A	20.79733427294842	106.89798933402452	1000	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
3	Bãi nuôi hàu B	20.793249193451075	106.89032987374179	1000	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
4	Bãi nuôi hàu C	20.793249246956822	106.88169403201009	1000	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
5	Bãi nuôi hàu D	20.790221270695948	106.85532378657973	1000	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
9	Bãi nuôi cá giò Cát Hải	20.81654250437656	106.86634647048794	1000	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
1	Bãi nuôi hàu Cát Hảiaaaa	20.805679913425646	106.89990787550379	1000	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
6	Rừng ngập mặn huyện Tiền Hải	20.23803735995301	106.56538722286332	1000	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
16	Bãi C	20.6571	106.8273	1354	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
17	Bãi D	20.6563	106.8255	1331	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
18	Bãi A	21.0806	107.3602	414	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
19	Bãi B	13.7147	109.2518	1861	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
20	Bãi B	21.0682	107.3987	601	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
21	Bãi Nam	20.8049	106.9524	1536	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
22	Bãi 1	15.4087	108.6168	338	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
25	Bãi 2	19.2548	106.9451	1566	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
26	Bãi Cháy	20.7142	106.7963	764	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
27	Bãi 2	15.3631	109.1591	583	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
28	Bãi C	18.7763	105.7705	1929	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
30	Bãi 1	15.4328	109.0651	1208	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
31	Bãi 1	19.2825	105.6728	149	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
32	Bãi 2	18.2495	106.0232	577	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
33	Bãi B	18.0579	106.3011	1262	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
34	Bãi A	18.0227	106.3015	890	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
35	Bãi Đen	20.6934	106.7962	933	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
36	Bãi B	18.7482	105.788	1318	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
37	Bãi 1	18.2797	106.0346	601	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
38	Bãi Cá Chớp	20.776	106.9555	1054	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
40	Bãi Test	19.3039	105.763607	1000	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
41	Rừng ngập mặn huyện Thái Thụy	20.57005905173713	106.5977587766479	1000	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
42	Rừng ngập mặn huyện Thái Thụy	20.57005905173713	106.5977587766479	1000	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
24	Bãi Yên Tử	20.7718	106.9055	257	oyster	fdca33cf-6b24-409b-9d07-46efb37051f5	991a48e3-03ec-4b2f-b2ea-509e5b119f36
43	Rừng ngập mặn huyện Thái Thụy	20.57005905173713	106.5977587766479	1000	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
44	Bãi nuôi cá giò vịnh Cái Bèo	20.729263681499532	107.05760892842237	1000	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
45	Bãi nuôi cá giò vịnh Cái Bèo	20.729263681499532	107.05760892842237	1000	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
46	Rừng ngập mặn huyện Thái Thụy	20.57005905173713	106.5977587766479	1000	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
\.


--
-- TOC entry 4928 (class 0 OID 296853)
-- Dependencies: 221
-- Data for Name: diagnose_naturalelements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnose_naturalelements (id, name) FROM stdin;
8	R_PO4
9	O2Sat
10	O2ml_L
11	STheta
12	Salnty
13	R_DYNHT
14	T_degC
15	R_Depth
16	Distance
17	Wind_Spd
18	Wave_Ht
19	Wave_Prd
20	IntChl
21	Dry_T
\.


--
-- TOC entry 4930 (class 0 OID 296857)
-- Dependencies: 223
-- Data for Name: diagnose_prediction_natureelements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnose_prediction_natureelements (id, prediction_id, nature_element_id, value) FROM stdin;
15	12	8	1.2
16	12	9	90.5
17	12	10	6.8
18	12	11	25.4
19	12	12	35.1
20	12	13	120.5
21	12	14	18.7
22	12	15	45.2
23	12	16	5.6
24	12	17	12.3
25	12	18	2.1
26	12	19	5.8
27	12	20	3.4
28	12	21	22.6
29	13	8	11
30	13	9	10
31	13	10	11
32	13	11	11
33	13	12	11
34	13	13	11
35	13	14	11
36	13	15	11
37	13	16	11
38	13	17	11
39	13	18	11
40	13	19	11
41	13	20	11
42	13	21	11
43	14	8	22
44	14	9	111
45	14	10	11
46	14	11	34
47	14	12	12
48	14	13	22
49	14	14	11
50	14	15	23
51	14	16	44
52	14	17	55
53	14	18	33
54	14	19	66
55	14	20	77
56	14	21	11
57	15	8	1.2
58	15	9	97
59	15	10	5
60	15	11	25
61	15	12	35
62	15	13	0.1
63	15	14	20
64	15	15	150
65	15	16	10
66	15	17	5
67	15	18	1
68	15	19	10
69	15	20	0.03
70	15	21	25
71	16	8	1.2
72	16	9	97
73	16	10	5
74	16	11	25
75	16	12	35
76	16	13	0.1
77	16	14	20
78	16	15	150
79	16	16	10
80	16	17	5
81	16	18	1
82	16	19	10
83	16	20	0.03
84	16	21	25
85	17	8	1
86	17	9	1
87	17	10	1
88	17	11	1
89	17	12	1
90	17	13	1
91	17	14	1
92	17	15	1
93	17	16	1
94	17	17	1
95	17	18	1
96	17	19	1
97	17	20	1
98	17	21	1
99	18	8	1.2
100	18	9	97
101	18	10	5
102	18	11	25
103	18	12	35
104	18	13	0.1
105	18	14	20
106	18	15	150
107	18	16	10
108	18	17	5
109	18	18	1
110	18	19	10
111	18	20	0.03
112	18	21	25
113	19	8	1.2
114	19	9	97
115	19	10	5
116	19	11	25
117	19	12	35
118	19	13	0.1
119	19	14	20
120	19	15	150
121	19	16	10
122	19	17	5
123	19	18	1
124	19	19	10
125	19	20	0.03
126	19	21	25
127	20	8	1.2
128	20	9	97
129	20	10	5
130	20	11	25
131	20	12	35
132	20	13	0.1
133	20	14	20
134	20	15	150
135	20	16	10
136	20	17	5
137	20	18	1
138	20	19	10
139	20	20	0.03
140	20	21	25
141	21	8	1
142	21	9	1
143	21	10	1
144	21	11	1
145	21	12	1
146	21	13	1
147	21	14	1
148	21	15	1
149	21	16	1
150	21	17	1
151	21	18	1
152	21	19	1
153	21	20	1
154	21	21	1
155	22	8	1.2
156	22	9	97
157	22	10	5
158	22	11	25
159	22	12	35
160	22	13	0.1
161	22	14	20
162	22	15	150
163	22	16	10
164	22	17	5
165	22	18	1
166	22	19	10
167	22	20	0.03
168	22	21	25
169	23	8	1.2
170	23	9	97
171	23	10	5
172	23	11	25
173	23	12	35
174	23	13	0.1
175	23	14	20
176	23	15	150
177	23	16	10
178	23	17	5
179	23	18	1
180	23	19	10
181	23	20	0.03
182	23	21	25
183	24	8	1.2
184	24	9	97
185	24	10	5
186	24	11	25
187	24	12	35
188	24	13	0.1
189	24	14	20
190	24	15	150
191	24	16	10
192	24	17	5
193	24	18	1
194	24	19	10
195	24	20	0.03
196	24	21	25
197	25	8	1
198	25	9	1
199	25	10	1
200	25	11	1
201	25	12	1
202	25	13	1
203	25	14	1
204	25	15	1
205	25	16	1
206	25	17	1
207	25	18	1
208	25	19	1
209	25	20	1
210	25	21	1
211	26	8	13
212	26	9	13
213	26	10	13
214	26	11	13
215	26	12	13
216	26	13	14
217	26	14	13
218	26	15	15
219	26	16	13
220	26	17	13
221	26	18	13
222	26	19	111
223	26	20	12
224	26	21	123
253	29	8	1
254	29	9	1
255	29	10	1
256	29	11	1
257	29	12	1
258	29	13	1
259	29	14	1
260	29	15	1
261	29	16	1
262	29	17	1
263	29	18	1
264	29	19	1
265	29	20	1
266	29	21	1
267	34	8	1
268	34	9	1
269	34	10	1
270	34	11	1
271	34	12	1
272	34	13	1
273	35	8	1
274	35	9	1
275	35	10	1
276	35	11	1
277	35	12	1
278	35	13	1
279	36	8	1
280	36	9	1
281	36	10	1
282	36	11	1
283	36	12	1
284	36	13	1
285	37	8	1
286	37	9	1
287	37	10	1
288	37	11	1
289	37	12	1
290	37	13	1
291	37	14	1
292	37	15	1
293	37	16	1
294	37	17	1
295	37	18	1
296	37	19	1
297	37	20	1
298	38	8	1
299	38	9	1
300	38	10	1
301	38	11	1
302	38	12	1
303	38	13	1
304	38	14	1
305	38	15	1
306	38	16	1
307	38	17	1
308	38	18	1
309	38	19	1
310	38	20	1
311	39	8	1
312	39	9	1
313	39	10	1
314	39	11	1
315	39	12	1
316	39	13	1
317	39	14	1
318	39	15	1
319	39	16	1
320	39	17	1
321	39	18	1
322	39	19	1
323	39	20	1
324	40	8	1
325	40	9	1
326	40	10	1
327	40	11	1
328	40	12	1
329	40	13	1
330	40	14	1
331	40	15	1
332	40	16	1
333	40	17	1
334	40	18	1
335	40	19	1
336	40	20	1
337	41	8	1
338	41	9	1
339	41	10	1
340	41	11	1
341	41	12	1
342	41	13	1
343	41	14	1
344	41	15	1
345	41	16	1
346	41	17	1
347	41	18	1
348	41	19	1
349	41	20	1
350	41	21	1
351	42	8	2
352	42	9	2
353	42	10	2
354	42	11	2
355	42	12	2
356	42	13	2
357	42	14	2
358	42	15	2
359	42	16	2
360	42	17	2
361	42	18	2
362	42	19	2
363	42	20	2
364	42	21	1
365	43	8	1
366	43	9	1
367	43	10	1
368	43	11	1
369	43	12	1
370	43	13	1
371	43	14	1
372	43	15	1
373	43	16	1
374	43	17	1
375	43	18	1
376	43	19	1
377	43	20	1
378	43	21	1
379	44	8	2
380	44	9	2
381	44	10	2
382	44	11	2
383	44	12	2
384	44	13	2
385	44	14	2
386	44	15	2
387	44	16	2
388	44	17	2
389	44	18	2
390	44	19	2
391	44	20	2
392	44	21	1
393	45	8	1
394	45	9	1
395	45	10	1
396	45	11	1
397	45	12	1
398	45	13	1
399	45	14	1
400	45	15	1
401	45	16	1
402	45	17	1
403	45	18	1
404	45	19	1
405	45	20	1
406	45	21	1
407	46	8	1
408	46	9	1
409	46	10	1
410	46	11	1
411	46	12	1
412	46	13	1
413	46	14	1
414	46	15	1
415	46	16	1
416	46	17	1
417	46	18	1
418	46	19	1
419	46	20	1
420	46	21	1
421	47	8	2
422	47	9	2
423	47	10	2
424	47	11	2
425	47	12	2
426	47	13	2
427	47	14	2
428	47	15	2
429	47	16	2
430	47	17	2
431	47	18	2
432	47	19	2
433	47	20	2
434	47	21	1
\.


--
-- TOC entry 4932 (class 0 OID 296861)
-- Dependencies: 225
-- Data for Name: diagnose_predictions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnose_predictions (id, user_id, area_id, prediction_text, "createdAt", "updatedAt") FROM stdin;
12	4	8	-1	2024-01-15 19:34:56+07	2024-01-15 19:34:56+07
13	3	2	-1	2024-02-14 15:00:00+07	2024-02-14 15:00:00+07
14	4	8	-1	2024-05-05 12:05:05+07	2024-05-05 12:05:05+07
15	5	3	-1	2024-11-11 18:11:11+07	2024-11-11 18:11:11+07
16	5	3	-1	2025-03-01 06:59:59+07	2025-03-01 06:59:59+07
17	3	2	3	2025-03-10 19:34:56+07	2025-03-10 19:34:56+07
18	5	3	-1	2025-03-15 15:05:12+07	2025-03-15 15:05:12+07
19	5	3	-1	2025-03-26 02:15:33+07	2025-03-26 02:15:33+07
20	4	3	-1	2025-03-31 04:45:12+07	2025-03-31 04:45:12+07
21	3	3	0	2025-03-10 19:34:56+07	2025-03-10 19:34:56+07
22	4	3	-1	2025-02-05 13:45:00+07	2025-02-05 13:45:00+07
23	3	3	-1	2024-12-15 12:45:23+07	2024-12-15 12:45:23+07
24	3	3	-1	2024-10-21 02:55:12+07	2024-10-21 02:55:12+07
25	3	5	13	2024-12-01 06:01:01+07	2024-12-01 06:01:01+07
26	3	4	-1	2025-03-15 15:05:12+07	2025-03-15 15:05:12+07
29	4	7	-1	2025-04-27 15:13:19.799+07	2025-04-27 15:13:19.802+07
30	4	7	-1	1970-01-01 07:00:00.001+07	2025-04-27 15:13:33.878+07
31	4	7	-1	1970-01-01 07:00:00.001+07	2025-04-27 15:14:22.121+07
32	4	7	-1	1970-01-01 07:00:00.001+07	2025-04-27 15:15:35.583+07
33	4	7	-1	1970-01-01 07:00:00.001+07	2025-04-27 15:16:05.422+07
34	4	7	-1	1970-01-01 07:00:00.001+07	2025-04-27 15:16:41.308+07
35	4	7	-1	1970-01-01 07:00:00.001+07	2025-04-27 15:17:32.899+07
36	4	7	-1	1970-01-01 07:00:00.001+07	2025-04-27 15:17:55.373+07
37	4	7	-1	1970-01-01 07:00:00.001+07	2025-04-27 15:18:30.512+07
38	4	7	-1	1970-01-01 07:00:00.001+07	2025-04-27 15:19:01.938+07
39	4	7	-1	1970-01-01 07:00:00.001+07	2025-04-27 15:21:46.531+07
40	4	7	-1	1970-01-01 07:00:00.001+07	2025-04-27 15:22:19.295+07
41	4	7	3	1970-01-01 07:00:00.001+07	2025-04-27 15:23:06.424+07
42	4	7	3	1970-01-01 07:00:00.001+07	2025-04-27 15:23:07.454+07
43	4	28	-1	1970-01-01 07:00:00.001+07	2025-05-10 22:31:52.428+07
44	4	28	-1	1970-01-01 07:00:00.001+07	2025-05-10 22:31:53.49+07
45	4	28	-1	2025-05-10 22:32:52.295+07	2025-05-10 22:32:52.295+07
46	4	13	-1	1970-01-01 07:00:00.001+07	2025-05-10 22:39:42.886+07
47	4	13	-1	1970-01-01 07:00:00.001+07	2025-05-10 22:39:43.952+07
\.


--
-- TOC entry 4937 (class 0 OID 296951)
-- Dependencies: 230
-- Data for Name: districts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.districts (id, name, lat, long, province_id) FROM stdin;
b246ae91-2e2e-4f29-8a6b-29be23b6e663	Hạ Long	20.9506	107.0733	f851f9a1-330b-4d29-98ae-f4092e7e7f70
eac6d35f-72a2-41b5-80c7-80f5d0e02c6a	Cẩm Phả	21.0161	107.3023	f851f9a1-330b-4d29-98ae-f4092e7e7f70
40ebf59b-c17e-43a6-a2cd-1f8c77daae92	Uông Bí	21.0322	106.7828	f851f9a1-330b-4d29-98ae-f4092e7e7f70
d97d8c8e-3e2a-49f3-bf03-8be56e7da5f4	Móng Cái	21.5247	107.9662	f851f9a1-330b-4d29-98ae-f4092e7e7f70
fc3e2551-e45c-4b6b-87a5-183cf2a8bfe0	Ngô Quyền	20.8565	106.6985	fb7e3341-2d65-44ba-868a-1c89c85e36a1
e1de6f8d-e46b-4e7a-b0d3-09bb7ae0b7e9	Lê Chân	20.8449	106.6926	fb7e3341-2d65-44ba-868a-1c89c85e36a1
55d45d30-c370-48e5-9502-3b1fc1af0e2a	Hồng Bàng	20.8665	106.676	fb7e3341-2d65-44ba-868a-1c89c85e36a1
ce9220ec-91e7-4b2d-9557-d7515ad1ce61	Đồ Sơn	20.7132	106.7769	fb7e3341-2d65-44ba-868a-1c89c85e36a1
3de66096-313d-48bb-a7a0-627263a09e92	Thái Bình	20.45	106.34	8830da77-668b-48d0-b2b6-91f2d3d3d136
726456e6-57ea-4a5c-9ab6-0b3c38a98906	Quỳnh Phụ	20.6716	106.3898	8830da77-668b-48d0-b2b6-91f2d3d3d136
d9a2ae38-9bbf-4440-bfdc-2b931c2d3728	Tiền Hải	20.3216	106.555	8830da77-668b-48d0-b2b6-91f2d3d3d136
338b586c-6a9e-40b2-bba8-7076f5ef41d8	Hưng Hà	20.6698	106.1782	8830da77-668b-48d0-b2b6-91f2d3d3d136
c3a5a8fa-6f7c-4df7-b3d2-32b2d5ec97d5	Ninh Bình	20.2519	105.9745	5e788a77-0373-4ac7-8d76-64f2a30883bc
b69fc5a6-72b0-417b-93e2-1265b25b3cb7	Tam Điệp	20.1441	105.8618	5e788a77-0373-4ac7-8d76-64f2a30883bc
00dd84c3-fd2d-40cf-b2a5-ef6b7efc95e2	Gia Viễn	20.375	105.9116	5e788a77-0373-4ac7-8d76-64f2a30883bc
2de0db20-2e45-4d24-b2ae-b2217e1a896e	Vinh	18.6796	105.6813	799ee009-6e6c-4e5d-b9a8-91ab717d3087
2e15900b-0f87-44e9-89be-b46e6900dfe7	Cửa Lò	18.8043	105.7234	799ee009-6e6c-4e5d-b9a8-91ab717d3087
2f868bf2-487d-4ae3-a3cf-d0e3553e8578	Quỳnh Lưu	19.2741	105.5874	799ee009-6e6c-4e5d-b9a8-91ab717d3087
a011eeca-3e29-4b46-b72a-2e8d8721ae53	Con Cuông	19.0676	104.8238	799ee009-6e6c-4e5d-b9a8-91ab717d3087
ec07e7b7-807e-415c-a6e2-5d87f091f4ba	Hà Tĩnh	18.3428	105.9057	10ef86e4-3851-44e9-8aeb-5cf21bbff1a2
392f0f7e-8599-45c8-b03b-0b2010c5b179	Kỳ Anh	18.0489	106.2997	10ef86e4-3851-44e9-8aeb-5cf21bbff1a2
7a66afdb-2722-41c1-8826-5cf3df41eafe	Hồng Lĩnh	18.5339	105.6951	10ef86e4-3851-44e9-8aeb-5cf21bbff1a2
991a48e3-03ec-4b2f-b2ea-509e5b119f36	Huế	16.4637	107.5909	fdca33cf-6b24-409b-9d07-46efb37051f5
6d273465-e0d0-4f21-8cf2-8900598b89ec	Hương Thủy	16.3738	107.7152	fdca33cf-6b24-409b-9d07-46efb37051f5
e72ee733-77ab-4f3b-99a2-9963707d4c0d	Phong Điền	16.555	107.4692	fdca33cf-6b24-409b-9d07-46efb37051f5
a8a2b1da-6cb3-4c1a-8c60-6f383fc33038	Tam Kỳ	15.5736	108.474	27d30196-bc1c-4cc3-bccd-e6df09909fa0
e55d19cd-d257-4c5b-8e9e-f624c44a4483	Hội An	15.8801	108.338	27d30196-bc1c-4cc3-bccd-e6df09909fa0
ee4bc1a1-16c7-489e-9552-bb782a3e2dce	Điện Bàn	15.8948	108.2035	27d30196-bc1c-4cc3-bccd-e6df09909fa0
665df479-786d-44da-90ad-c77d493c18f7	Quảng Ngãi	15.1216	108.8043	2b708477-89e2-4f2c-98ce-11c6de5d9d1a
a3c6f9f5-5058-443e-8c4e-7e9e3b6d5615	Đức Phổ	14.8397	109.0134	2b708477-89e2-4f2c-98ce-11c6de5d9d1a
ab02b04a-b3fc-4e5f-94e8-f27de6016c50	Sơn Tịnh	15.2124	108.7422	2b708477-89e2-4f2c-98ce-11c6de5d9d1a
5ea9b0d1-5f54-456d-939f-bf7592b51d29	Nha Trang	12.2388	109.1967	0516f5a8-0e1e-4c95-90f7-50e59c99ad20
6c9e1e03-2d6f-4b17-83f8-c2b3e79dbe81	Cam Ranh	11.9214	109.1597	0516f5a8-0e1e-4c95-90f7-50e59c99ad20
110b11e2-35e1-41e4-9d0a-14cb23efbd6f	Ninh Hòa	12.5356	109.0912	0516f5a8-0e1e-4c95-90f7-50e59c99ad20
\.


--
-- TOC entry 4936 (class 0 OID 296946)
-- Dependencies: 229
-- Data for Name: provinces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.provinces (id, name) FROM stdin;
f851f9a1-330b-4d29-98ae-f4092e7e7f70	Quảng Ninh
fb7e3341-2d65-44ba-868a-1c89c85e36a1	Hải Phòng
8830da77-668b-48d0-b2b6-91f2d3d3d136	Thái Bình
5e788a77-0373-4ac7-8d76-64f2a30883bc	Ninh Bình
799ee009-6e6c-4e5d-b9a8-91ab717d3087	Nghệ An
10ef86e4-3851-44e9-8aeb-5cf21bbff1a2	Hà Tĩnh
fdca33cf-6b24-409b-9d07-46efb37051f5	Thừa Thiên Huế
27d30196-bc1c-4cc3-bccd-e6df09909fa0	Quảng Nam
2b708477-89e2-4f2c-98ce-11c6de5d9d1a	Quảng Ngãi
0516f5a8-0e1e-4c95-90f7-50e59c99ad20	Khánh Hòa
\.


--
-- TOC entry 4934 (class 0 OID 296882)
-- Dependencies: 227
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password, role, email, address, phone, status, province, district) FROM stdin;
5	nghiem.eo.bua.18	$2b$10$Wuk6i5.psEePYk78HjdrGed2B8DcXOxUDG292OzhV6BKnUBBgtZza	expert	nghiem.eo.bua.1@gmail.com	82 Ngo Quyen 	0111111111	active	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
3	administrator	$2b$10$8drYopD10fl9OyxWHCybXeDccD4h2sZa4v2sx5FmDP/RBLfYhv7LO	admin	administrator@gmail.com	82 Ngo Quyen 	0111111111	active	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
4	manager1	$2b$10$yvYCht8x1OP3WQRUJlTgWOKoCU5rux22RaK9VwVChWJJzU7O9Rsk.	expert	manager@gmail.com	82 Ngo Quyen.St	0111111113	active	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
6	nghiem1	$2b$10$0jw8EJoMR7wbpyYOeca16OLA9tx.ege84z/FCbLtqMr5zoHTGjDbi	manager	nghiem1@gmail.com	82 Ngo Quyen 	0111111114	active	f851f9a1-330b-4d29-98ae-f4092e7e7f70	\N
8	nghiem2	$2b$10$8AffzeFiRtdFeml3W5RRyOPg4w4/2RgRdlbX56Yc9.Vop6fy16mGi	manager	nghiem2@gmail.com	82 Ngo Quyen 	0111111112	active	f851f9a1-330b-4d29-98ae-f4092e7e7f70	d97d8c8e-3e2a-49f3-bf03-8be56e7da5f4
\.


--
-- TOC entry 4949 (class 0 OID 0)
-- Dependencies: 220
-- Name: diagnose_areas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_areas_id_seq', 46, true);


--
-- TOC entry 4950 (class 0 OID 0)
-- Dependencies: 222
-- Name: diagnose_naturalelements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_naturalelements_id_seq', 21, true);


--
-- TOC entry 4951 (class 0 OID 0)
-- Dependencies: 224
-- Name: diagnose_prediction_natureelements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_prediction_natureelements_id_seq', 434, true);


--
-- TOC entry 4952 (class 0 OID 0)
-- Dependencies: 226
-- Name: diagnose_predictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_predictions_id_seq', 47, true);


--
-- TOC entry 4953 (class 0 OID 0)
-- Dependencies: 228
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 8, true);


--
-- TOC entry 4756 (class 2606 OID 296897)
-- Name: SequelizeMeta SequelizeMeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SequelizeMeta"
    ADD CONSTRAINT "SequelizeMeta_pkey" PRIMARY KEY (name);


--
-- TOC entry 4758 (class 2606 OID 296899)
-- Name: diagnose_areas diagnose_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_areas
    ADD CONSTRAINT diagnose_areas_pkey PRIMARY KEY (id);


--
-- TOC entry 4760 (class 2606 OID 296901)
-- Name: diagnose_naturalelements diagnose_naturalelements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_naturalelements
    ADD CONSTRAINT diagnose_naturalelements_pkey PRIMARY KEY (id);


--
-- TOC entry 4762 (class 2606 OID 296903)
-- Name: diagnose_prediction_natureelements diagnose_prediction_natureelements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements
    ADD CONSTRAINT diagnose_prediction_natureelements_pkey PRIMARY KEY (id);


--
-- TOC entry 4764 (class 2606 OID 296905)
-- Name: diagnose_predictions diagnose_predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions
    ADD CONSTRAINT diagnose_predictions_pkey PRIMARY KEY (id);


--
-- TOC entry 4772 (class 2606 OID 296955)
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- TOC entry 4770 (class 2606 OID 296950)
-- Name: provinces provinces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provinces
    ADD CONSTRAINT provinces_pkey PRIMARY KEY (id);


--
-- TOC entry 4766 (class 2606 OID 296913)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4768 (class 2606 OID 296915)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 4775 (class 2606 OID 296921)
-- Name: diagnose_prediction_natureelements diagnose_prediction_natureelements_nature_element_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements
    ADD CONSTRAINT diagnose_prediction_natureelements_nature_element_id_fkey FOREIGN KEY (nature_element_id) REFERENCES public.diagnose_naturalelements(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4776 (class 2606 OID 296926)
-- Name: diagnose_prediction_natureelements diagnose_prediction_natureelements_prediction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements
    ADD CONSTRAINT diagnose_prediction_natureelements_prediction_id_fkey FOREIGN KEY (prediction_id) REFERENCES public.diagnose_predictions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4777 (class 2606 OID 296931)
-- Name: diagnose_predictions diagnose_predictions_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions
    ADD CONSTRAINT diagnose_predictions_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.diagnose_areas(id) ON UPDATE CASCADE;


--
-- TOC entry 4778 (class 2606 OID 296936)
-- Name: diagnose_predictions diagnose_predictions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions
    ADD CONSTRAINT diagnose_predictions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE;


--
-- TOC entry 4779 (class 2606 OID 296956)
-- Name: districts districts_province_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_province_id_fkey FOREIGN KEY (province_id) REFERENCES public.provinces(id);


--
-- TOC entry 4773 (class 2606 OID 296966)
-- Name: diagnose_areas fk_district; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_areas
    ADD CONSTRAINT fk_district FOREIGN KEY (district) REFERENCES public.districts(id);


--
-- TOC entry 4774 (class 2606 OID 296961)
-- Name: diagnose_areas fk_province; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_areas
    ADD CONSTRAINT fk_province FOREIGN KEY (province) REFERENCES public.provinces(id);


-- Completed on 2025-06-08 11:26:23

--
-- PostgreSQL database dump complete
--

