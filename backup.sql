--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2025-03-02 15:32:26

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
-- TOC entry 873 (class 1247 OID 25450)
-- Name: enum_diagnose_areas_area_type; Type: TYPE; Schema: public; Owner: postgres
--
CREATE TYPE public.enum_diagnose_areas_area_type AS ENUM (
    'oyster',
    'cobia'
);


ALTER TYPE public.enum_diagnose_areas_area_type OWNER TO postgres;

--
-- TOC entry 870 (class 1247 OID 24911)
-- Name: enum_users_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_users_role AS ENUM (
    'expert',
    'admin'
);


ALTER TYPE public.enum_users_role OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 24857)
-- Name: diagnose_areas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diagnose_areas (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    address character varying(255) NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    area double precision NOT NULL,
    area_type public.enum_diagnose_areas_area_type NOT NULL,
    CONSTRAINT diagnose_areas_area_type_check CHECK (((area_type)::text = ANY (ARRAY[('oyster'::character varying)::text, ('cobia'::character varying)::text])))
);


ALTER TABLE public.diagnose_areas OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 24856)
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
-- TOC entry 5176 (class 0 OID 0)
-- Dependencies: 219
-- Name: diagnose_areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diagnose_areas_id_seq OWNED BY public.diagnose_areas.id;


--
-- TOC entry 222 (class 1259 OID 24867)
-- Name: diagnose_naturalelements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diagnose_naturalelements (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.diagnose_naturalelements OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 24866)
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
-- TOC entry 5177 (class 0 OID 0)
-- Dependencies: 221
-- Name: diagnose_naturalelements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diagnose_naturalelements_id_seq OWNED BY public.diagnose_naturalelements.id;


--
-- TOC entry 226 (class 1259 OID 24894)
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
-- TOC entry 225 (class 1259 OID 24893)
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
-- TOC entry 5178 (class 0 OID 0)
-- Dependencies: 225
-- Name: diagnose_prediction_natureelements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diagnose_prediction_natureelements_id_seq OWNED BY public.diagnose_prediction_natureelements.id;


--
-- TOC entry 224 (class 1259 OID 24874)
-- Name: diagnose_predictions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diagnose_predictions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    area_id integer NOT NULL,
    prediction_text text NOT NULL  
    "createdAt" timestamp with time zone NOT NULL DEFAULT now(),
    "updatedAt" timestamp with time zone NOT NULL DEFAULT now()
);


ALTER TABLE public.diagnose_predictions OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 24873)
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
-- TOC entry 5179 (class 0 OID 0)
-- Dependencies: 223
-- Name: diagnose_predictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diagnose_predictions_id_seq OWNED BY public.diagnose_predictions.id;


--
-- TOC entry 218 (class 1259 OID 24845)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    role public.enum_users_role NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY (ARRAY[('end_user'::character varying)::text, ('expert'::character varying)::text, ('admin'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 24844)
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
-- TOC entry 5180 (class 0 OID 0)
-- Dependencies: 217
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4722 (class 2604 OID 24860)
-- Name: diagnose_areas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_areas ALTER COLUMN id SET DEFAULT nextval('public.diagnose_areas_id_seq'::regclass);


--
-- TOC entry 4723 (class 2604 OID 24870)
-- Name: diagnose_naturalelements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_naturalelements ALTER COLUMN id SET DEFAULT nextval('public.diagnose_naturalelements_id_seq'::regclass);


--
-- TOC entry 4725 (class 2604 OID 24897)
-- Name: diagnose_prediction_natureelements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements ALTER COLUMN id SET DEFAULT nextval('public.diagnose_prediction_natureelements_id_seq'::regclass);


--
-- TOC entry 4724 (class 2604 OID 24877)
-- Name: diagnose_predictions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions ALTER COLUMN id SET DEFAULT nextval('public.diagnose_predictions_id_seq'::regclass);


--
-- TOC entry 4721 (class 2604 OID 24848)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5164 (class 0 OID 24857)
-- Dependencies: 220
-- Data for Name: diagnose_areas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnose_areas (id, name, address, latitude, longitude, area, area_type) FROM stdin;
1	Bãi nuôi hàu Cát Hải	Cát Hải, Hải Phòng	20.805679913425646	106.89990787550379	1000	oyster
2	Bãi nuôi hàu A	Cát Hải, Hải Phòng	20.79733427294842	106.89798933402452	1000	oyster
3	Bãi nuôi hàu B	Cát Hải, Hải Phòng	20.793249193451075	106.89032987374179	1000	oyster
4	Bãi nuôi hàu C	Cát Hải, Hải Phòng	20.793249246956822	106.88169403201009	1000	oyster
5	Bãi nuôi hàu D	Cát Hải, Hải Phòng	20.790221270695948	106.85532378657973	1000	oyster
6	Rừng ngập mặn huyện Tiền Hải	Tiền Hải, Thái Bình	20.23803735995301	106.56538722286332	1000	oyster
7	Rừng ngập mặn huyện Thái Thụy	Thái Thụy, Thái Bình	20.57005905173713	106.5977587766479	1000	oyster
8	Bãi nuôi cá giò vịnh Cái Bèo	Cát Bà, Hải Phòng	20.729263681499532	107.05760892842237	1000	cobia
9	Bãi nuôi cá giò Cát Hải	Cát Hải, Hải Phòng	20.81654250437656	106.86634647048794	1000	cobia
\.


--
-- TOC entry 5166 (class 0 OID 24867)
-- Dependencies: 222
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
-- TOC entry 5170 (class 0 OID 24894)
-- Dependencies: 226
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
\.


--
-- TOC entry 5168 (class 0 OID 24874)
-- Dependencies: 224
-- Data for Name: diagnose_predictions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnose_predictions (id, user_id, area_id, prediction_text,createdAt,updatedAt) FROM stdin;
12	2	8	-1	2024-01-15T12:34:56.000Z    2024-01-15T12:34:56.000Z
13	2	2	-1  2024-02-14T08:00:00.000Z    2024-02-14T08:00:00.000Z
14	2	8	-1  2024-05-05T05:05:05.000Z    2024-05-05T05:05:05.000Z
15	1	3	-1  2024-11-11T11:11:11.000Z    2024-11-11T11:11:11.000Z
16	1	3	-1  2025-02-28T23:59:59.000Z    2025-02-28T23:59:59.000Z
17	2	2	3   2025-03-10T12:34:56.000Z    2025-03-10T12:34:56.000Z
18	2	3	-1  2025-03-15T08:05:12.000Z    2025-03-15T08:05:12.000Z
19	2	3	-1  2025-03-25T19:15:33.000Z    2025-03-25T19:15:33.000Z
20	2	3	-1  2025-03-30T21:45:12.000Z    2025-03-30T21:45:12.000Z
21	2	3	0   2025-03-10T12:34:56.000Z    2025-03-10T12:34:56.000Z
22	2	3	-1  2025-02-05T06:45:00.000Z    2025-02-05T06:45:00.000Z
23	2	3	-1  2024-12-15T05:45:23.000Z    2024-12-15T05:45:23.000Z
24	2	3	-1  2024-10-20T19:55:12.000Z    2024-10-20T19:55:12.000Z
25	2	5	13  2024-11-30T23:01:01.000Z    2024-11-30T23:01:01.000Z
26	2	4	-1  2025-03-15T08:05:12.000Z    2025-03-15T08:05:12.000Z
\.


--
-- TOC entry 5162 (class 0 OID 24845)
-- Dependencies: 218
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name,email, password, role) FROM stdin;
1	Admin1 admin1@gmail.com	$2b$10$8drYopD10fl9OyxWHCybXeDccD4h2sZa4v2sx5FmDP/RBLfYhv7LO	admin
2	Expert1 expert1@gmail.com	$2b$10$Wuk6i5.psEePYk78HjdrGed2B8DcXOxUDG292OzhV6BKnUBBgtZza	expert
\.


--
-- TOC entry 5181 (class 0 OID 0)
-- Dependencies: 219
-- Name: diagnose_areas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_areas_id_seq', 9, true);


--
-- TOC entry 5182 (class 0 OID 0)
-- Dependencies: 221
-- Name: diagnose_naturalelements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_naturalelements_id_seq', 21, true);


--
-- TOC entry 5183 (class 0 OID 0)
-- Dependencies: 225
-- Name: diagnose_prediction_natureelements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_prediction_natureelements_id_seq', 224, true);


--
-- TOC entry 5184 (class 0 OID 0)
-- Dependencies: 223
-- Name: diagnose_predictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_predictions_id_seq', 26, true);


--
-- TOC entry 5185 (class 0 OID 0)
-- Dependencies: 217
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 2, true);


--
-- TOC entry 5005 (class 2606 OID 24865)
-- Name: diagnose_areas diagnose_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_areas
    ADD CONSTRAINT diagnose_areas_pkey PRIMARY KEY (id);


--
-- TOC entry 5007 (class 2606 OID 24872)
-- Name: diagnose_naturalelements diagnose_naturalelements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_naturalelements
    ADD CONSTRAINT diagnose_naturalelements_pkey PRIMARY KEY (id);


--
-- TOC entry 5011 (class 2606 OID 24899)
-- Name: diagnose_prediction_natureelements diagnose_prediction_natureelements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements
    ADD CONSTRAINT diagnose_prediction_natureelements_pkey PRIMARY KEY (id);


--
-- TOC entry 5009 (class 2606 OID 24882)
-- Name: diagnose_predictions diagnose_predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions
    ADD CONSTRAINT diagnose_predictions_pkey PRIMARY KEY (id);


--
-- TOC entry 4729 (class 2606 OID 24853)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4731 (class 2606 OID 47255)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 4733 (class 2606 OID 47257)
-- Name: users users_username_key1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key1 UNIQUE (username);


--
-- TOC entry 4735 (class 2606 OID 47093)
-- Name: users users_username_key10; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key10 UNIQUE (username);


--
-- TOC entry 4737 (class 2606 OID 47165)
-- Name: users users_username_key100; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key100 UNIQUE (username);


--
-- TOC entry 4739 (class 2606 OID 47053)
-- Name: users users_username_key101; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key101 UNIQUE (username);


--
-- TOC entry 4741 (class 2606 OID 47055)
-- Name: users users_username_key102; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key102 UNIQUE (username);


--
-- TOC entry 4743 (class 2606 OID 47163)
-- Name: users users_username_key103; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key103 UNIQUE (username);


--
-- TOC entry 4745 (class 2606 OID 47015)
-- Name: users users_username_key104; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key104 UNIQUE (username);


--
-- TOC entry 4747 (class 2606 OID 47017)
-- Name: users users_username_key105; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key105 UNIQUE (username);


--
-- TOC entry 4749 (class 2606 OID 47161)
-- Name: users users_username_key106; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key106 UNIQUE (username);


--
-- TOC entry 4751 (class 2606 OID 47159)
-- Name: users users_username_key107; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key107 UNIQUE (username);


--
-- TOC entry 4753 (class 2606 OID 47019)
-- Name: users users_username_key108; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key108 UNIQUE (username);


--
-- TOC entry 4755 (class 2606 OID 47069)
-- Name: users users_username_key109; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key109 UNIQUE (username);


--
-- TOC entry 4757 (class 2606 OID 47095)
-- Name: users users_username_key11; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key11 UNIQUE (username);


--
-- TOC entry 4759 (class 2606 OID 47021)
-- Name: users users_username_key110; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key110 UNIQUE (username);


--
-- TOC entry 4761 (class 2606 OID 47067)
-- Name: users users_username_key111; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key111 UNIQUE (username);


--
-- TOC entry 4763 (class 2606 OID 47023)
-- Name: users users_username_key112; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key112 UNIQUE (username);


--
-- TOC entry 4765 (class 2606 OID 47065)
-- Name: users users_username_key113; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key113 UNIQUE (username);


--
-- TOC entry 4767 (class 2606 OID 47025)
-- Name: users users_username_key114; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key114 UNIQUE (username);


--
-- TOC entry 4769 (class 2606 OID 47063)
-- Name: users users_username_key115; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key115 UNIQUE (username);


--
-- TOC entry 4771 (class 2606 OID 47027)
-- Name: users users_username_key116; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key116 UNIQUE (username);


--
-- TOC entry 4773 (class 2606 OID 47061)
-- Name: users users_username_key117; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key117 UNIQUE (username);


--
-- TOC entry 4775 (class 2606 OID 47029)
-- Name: users users_username_key118; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key118 UNIQUE (username);


--
-- TOC entry 4777 (class 2606 OID 47059)
-- Name: users users_username_key119; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key119 UNIQUE (username);


--
-- TOC entry 4779 (class 2606 OID 47251)
-- Name: users users_username_key12; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key12 UNIQUE (username);


--
-- TOC entry 4781 (class 2606 OID 47031)
-- Name: users users_username_key120; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key120 UNIQUE (username);


--
-- TOC entry 4783 (class 2606 OID 47057)
-- Name: users users_username_key121; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key121 UNIQUE (username);


--
-- TOC entry 4785 (class 2606 OID 47033)
-- Name: users users_username_key122; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key122 UNIQUE (username);


--
-- TOC entry 4787 (class 2606 OID 47077)
-- Name: users users_username_key123; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key123 UNIQUE (username);


--
-- TOC entry 4789 (class 2606 OID 47071)
-- Name: users users_username_key124; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key124 UNIQUE (username);


--
-- TOC entry 4791 (class 2606 OID 47073)
-- Name: users users_username_key125; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key125 UNIQUE (username);


--
-- TOC entry 4793 (class 2606 OID 47075)
-- Name: users users_username_key126; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key126 UNIQUE (username);


--
-- TOC entry 4795 (class 2606 OID 47157)
-- Name: users users_username_key127; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key127 UNIQUE (username);


--
-- TOC entry 4797 (class 2606 OID 47149)
-- Name: users users_username_key128; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key128 UNIQUE (username);


--
-- TOC entry 4799 (class 2606 OID 47155)
-- Name: users users_username_key129; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key129 UNIQUE (username);


--
-- TOC entry 4801 (class 2606 OID 47097)
-- Name: users users_username_key13; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key13 UNIQUE (username);


--
-- TOC entry 4803 (class 2606 OID 47151)
-- Name: users users_username_key130; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key130 UNIQUE (username);


--
-- TOC entry 4805 (class 2606 OID 47153)
-- Name: users users_username_key131; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key131 UNIQUE (username);


--
-- TOC entry 4807 (class 2606 OID 47009)
-- Name: users users_username_key132; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key132 UNIQUE (username);


--
-- TOC entry 4809 (class 2606 OID 47003)
-- Name: users users_username_key133; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key133 UNIQUE (username);


--
-- TOC entry 4811 (class 2606 OID 47007)
-- Name: users users_username_key134; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key134 UNIQUE (username);


--
-- TOC entry 4813 (class 2606 OID 47005)
-- Name: users users_username_key135; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key135 UNIQUE (username);


--
-- TOC entry 4815 (class 2606 OID 46989)
-- Name: users users_username_key136; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key136 UNIQUE (username);


--
-- TOC entry 4817 (class 2606 OID 47135)
-- Name: users users_username_key14; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key14 UNIQUE (username);


--
-- TOC entry 4819 (class 2606 OID 47137)
-- Name: users users_username_key15; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key15 UNIQUE (username);


--
-- TOC entry 4821 (class 2606 OID 47139)
-- Name: users users_username_key16; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key16 UNIQUE (username);


--
-- TOC entry 4823 (class 2606 OID 47141)
-- Name: users users_username_key17; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key17 UNIQUE (username);


--
-- TOC entry 4825 (class 2606 OID 47143)
-- Name: users users_username_key18; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key18 UNIQUE (username);


--
-- TOC entry 4827 (class 2606 OID 47249)
-- Name: users users_username_key19; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key19 UNIQUE (username);


--
-- TOC entry 4829 (class 2606 OID 47259)
-- Name: users users_username_key2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key2 UNIQUE (username);


--
-- TOC entry 4831 (class 2606 OID 47181)
-- Name: users users_username_key20; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key20 UNIQUE (username);


--
-- TOC entry 4833 (class 2606 OID 47247)
-- Name: users users_username_key21; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key21 UNIQUE (username);


--
-- TOC entry 4835 (class 2606 OID 47193)
-- Name: users users_username_key22; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key22 UNIQUE (username);


--
-- TOC entry 4837 (class 2606 OID 47195)
-- Name: users users_username_key23; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key23 UNIQUE (username);


--
-- TOC entry 4839 (class 2606 OID 47197)
-- Name: users users_username_key24; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key24 UNIQUE (username);


--
-- TOC entry 4841 (class 2606 OID 47199)
-- Name: users users_username_key25; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key25 UNIQUE (username);


--
-- TOC entry 4843 (class 2606 OID 47201)
-- Name: users users_username_key26; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key26 UNIQUE (username);


--
-- TOC entry 4845 (class 2606 OID 47245)
-- Name: users users_username_key27; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key27 UNIQUE (username);


--
-- TOC entry 4847 (class 2606 OID 47205)
-- Name: users users_username_key28; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key28 UNIQUE (username);


--
-- TOC entry 4849 (class 2606 OID 47207)
-- Name: users users_username_key29; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key29 UNIQUE (username);


--
-- TOC entry 4851 (class 2606 OID 47261)
-- Name: users users_username_key3; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key3 UNIQUE (username);


--
-- TOC entry 4853 (class 2606 OID 47243)
-- Name: users users_username_key30; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key30 UNIQUE (username);


--
-- TOC entry 4855 (class 2606 OID 47209)
-- Name: users users_username_key31; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key31 UNIQUE (username);


--
-- TOC entry 4857 (class 2606 OID 47211)
-- Name: users users_username_key32; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key32 UNIQUE (username);


--
-- TOC entry 4859 (class 2606 OID 47241)
-- Name: users users_username_key33; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key33 UNIQUE (username);


--
-- TOC entry 4861 (class 2606 OID 47213)
-- Name: users users_username_key34; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key34 UNIQUE (username);


--
-- TOC entry 4863 (class 2606 OID 47239)
-- Name: users users_username_key35; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key35 UNIQUE (username);


--
-- TOC entry 4865 (class 2606 OID 47215)
-- Name: users users_username_key36; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key36 UNIQUE (username);


--
-- TOC entry 4867 (class 2606 OID 47217)
-- Name: users users_username_key37; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key37 UNIQUE (username);


--
-- TOC entry 4869 (class 2606 OID 47219)
-- Name: users users_username_key38; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key38 UNIQUE (username);


--
-- TOC entry 4871 (class 2606 OID 47203)
-- Name: users users_username_key39; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key39 UNIQUE (username);


--
-- TOC entry 4873 (class 2606 OID 47083)
-- Name: users users_username_key4; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key4 UNIQUE (username);


--
-- TOC entry 4875 (class 2606 OID 46991)
-- Name: users users_username_key40; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key40 UNIQUE (username);


--
-- TOC entry 4877 (class 2606 OID 46993)
-- Name: users users_username_key41; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key41 UNIQUE (username);


--
-- TOC entry 4879 (class 2606 OID 46995)
-- Name: users users_username_key42; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key42 UNIQUE (username);


--
-- TOC entry 4881 (class 2606 OID 46997)
-- Name: users users_username_key43; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key43 UNIQUE (username);


--
-- TOC entry 4883 (class 2606 OID 47081)
-- Name: users users_username_key44; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key44 UNIQUE (username);


--
-- TOC entry 4885 (class 2606 OID 46999)
-- Name: users users_username_key45; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key45 UNIQUE (username);


--
-- TOC entry 4887 (class 2606 OID 47001)
-- Name: users users_username_key46; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key46 UNIQUE (username);


--
-- TOC entry 4889 (class 2606 OID 47011)
-- Name: users users_username_key47; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key47 UNIQUE (username);


--
-- TOC entry 4891 (class 2606 OID 47013)
-- Name: users users_username_key48; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key48 UNIQUE (username);


--
-- TOC entry 4893 (class 2606 OID 47079)
-- Name: users users_username_key49; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key49 UNIQUE (username);


--
-- TOC entry 4895 (class 2606 OID 47085)
-- Name: users users_username_key5; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key5 UNIQUE (username);


--
-- TOC entry 4897 (class 2606 OID 47233)
-- Name: users users_username_key50; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key50 UNIQUE (username);


--
-- TOC entry 4899 (class 2606 OID 47235)
-- Name: users users_username_key51; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key51 UNIQUE (username);


--
-- TOC entry 4901 (class 2606 OID 47237)
-- Name: users users_username_key52; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key52 UNIQUE (username);


--
-- TOC entry 4903 (class 2606 OID 47191)
-- Name: users users_username_key53; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key53 UNIQUE (username);


--
-- TOC entry 4905 (class 2606 OID 47183)
-- Name: users users_username_key54; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key54 UNIQUE (username);


--
-- TOC entry 4907 (class 2606 OID 47189)
-- Name: users users_username_key55; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key55 UNIQUE (username);


--
-- TOC entry 4909 (class 2606 OID 47185)
-- Name: users users_username_key56; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key56 UNIQUE (username);


--
-- TOC entry 4911 (class 2606 OID 47187)
-- Name: users users_username_key57; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key57 UNIQUE (username);


--
-- TOC entry 4913 (class 2606 OID 47099)
-- Name: users users_username_key58; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key58 UNIQUE (username);


--
-- TOC entry 4915 (class 2606 OID 47123)
-- Name: users users_username_key59; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key59 UNIQUE (username);


--
-- TOC entry 4917 (class 2606 OID 47087)
-- Name: users users_username_key6; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key6 UNIQUE (username);


--
-- TOC entry 4919 (class 2606 OID 47133)
-- Name: users users_username_key60; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key60 UNIQUE (username);


--
-- TOC entry 4921 (class 2606 OID 47125)
-- Name: users users_username_key61; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key61 UNIQUE (username);


--
-- TOC entry 4923 (class 2606 OID 47127)
-- Name: users users_username_key62; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key62 UNIQUE (username);


--
-- TOC entry 4925 (class 2606 OID 47129)
-- Name: users users_username_key63; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key63 UNIQUE (username);


--
-- TOC entry 4927 (class 2606 OID 47131)
-- Name: users users_username_key64; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key64 UNIQUE (username);


--
-- TOC entry 4929 (class 2606 OID 47121)
-- Name: users users_username_key65; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key65 UNIQUE (username);


--
-- TOC entry 4931 (class 2606 OID 47101)
-- Name: users users_username_key66; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key66 UNIQUE (username);


--
-- TOC entry 4933 (class 2606 OID 47119)
-- Name: users users_username_key67; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key67 UNIQUE (username);


--
-- TOC entry 4935 (class 2606 OID 47117)
-- Name: users users_username_key68; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key68 UNIQUE (username);


--
-- TOC entry 4937 (class 2606 OID 47103)
-- Name: users users_username_key69; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key69 UNIQUE (username);


--
-- TOC entry 4939 (class 2606 OID 47253)
-- Name: users users_username_key7; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key7 UNIQUE (username);


--
-- TOC entry 4941 (class 2606 OID 47115)
-- Name: users users_username_key70; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key70 UNIQUE (username);


--
-- TOC entry 4943 (class 2606 OID 47105)
-- Name: users users_username_key71; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key71 UNIQUE (username);


--
-- TOC entry 4945 (class 2606 OID 47107)
-- Name: users users_username_key72; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key72 UNIQUE (username);


--
-- TOC entry 4947 (class 2606 OID 47113)
-- Name: users users_username_key73; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key73 UNIQUE (username);


--
-- TOC entry 4949 (class 2606 OID 47109)
-- Name: users users_username_key74; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key74 UNIQUE (username);


--
-- TOC entry 4951 (class 2606 OID 47111)
-- Name: users users_username_key75; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key75 UNIQUE (username);


--
-- TOC entry 4953 (class 2606 OID 47231)
-- Name: users users_username_key76; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key76 UNIQUE (username);


--
-- TOC entry 4955 (class 2606 OID 47221)
-- Name: users users_username_key77; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key77 UNIQUE (username);


--
-- TOC entry 4957 (class 2606 OID 47229)
-- Name: users users_username_key78; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key78 UNIQUE (username);


--
-- TOC entry 4959 (class 2606 OID 47227)
-- Name: users users_username_key79; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key79 UNIQUE (username);


--
-- TOC entry 4961 (class 2606 OID 47089)
-- Name: users users_username_key8; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key8 UNIQUE (username);


--
-- TOC entry 4963 (class 2606 OID 47223)
-- Name: users users_username_key80; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key80 UNIQUE (username);


--
-- TOC entry 4965 (class 2606 OID 47225)
-- Name: users users_username_key81; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key81 UNIQUE (username);


--
-- TOC entry 4967 (class 2606 OID 47145)
-- Name: users users_username_key82; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key82 UNIQUE (username);


--
-- TOC entry 4969 (class 2606 OID 47147)
-- Name: users users_username_key83; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key83 UNIQUE (username);


--
-- TOC entry 4971 (class 2606 OID 47035)
-- Name: users users_username_key84; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key84 UNIQUE (username);


--
-- TOC entry 4973 (class 2606 OID 47179)
-- Name: users users_username_key85; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key85 UNIQUE (username);


--
-- TOC entry 4975 (class 2606 OID 47037)
-- Name: users users_username_key86; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key86 UNIQUE (username);


--
-- TOC entry 4977 (class 2606 OID 47039)
-- Name: users users_username_key87; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key87 UNIQUE (username);


--
-- TOC entry 4979 (class 2606 OID 47177)
-- Name: users users_username_key88; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key88 UNIQUE (username);


--
-- TOC entry 4981 (class 2606 OID 47041)
-- Name: users users_username_key89; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key89 UNIQUE (username);


--
-- TOC entry 4983 (class 2606 OID 47091)
-- Name: users users_username_key9; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key9 UNIQUE (username);


--
-- TOC entry 4985 (class 2606 OID 47043)
-- Name: users users_username_key90; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key90 UNIQUE (username);


--
-- TOC entry 4987 (class 2606 OID 47175)
-- Name: users users_username_key91; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key91 UNIQUE (username);


--
-- TOC entry 4989 (class 2606 OID 47045)
-- Name: users users_username_key92; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key92 UNIQUE (username);


--
-- TOC entry 4991 (class 2606 OID 47047)
-- Name: users users_username_key93; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key93 UNIQUE (username);


--
-- TOC entry 4993 (class 2606 OID 47173)
-- Name: users users_username_key94; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key94 UNIQUE (username);


--
-- TOC entry 4995 (class 2606 OID 47169)
-- Name: users users_username_key95; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key95 UNIQUE (username);


--
-- TOC entry 4997 (class 2606 OID 47171)
-- Name: users users_username_key96; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key96 UNIQUE (username);


--
-- TOC entry 4999 (class 2606 OID 47167)
-- Name: users users_username_key97; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key97 UNIQUE (username);


--
-- TOC entry 5001 (class 2606 OID 47049)
-- Name: users users_username_key98; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key98 UNIQUE (username);


--
-- TOC entry 5003 (class 2606 OID 47051)
-- Name: users users_username_key99; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key99 UNIQUE (username);


--
-- TOC entry 5014 (class 2606 OID 47279)
-- Name: diagnose_prediction_natureelements diagnose_prediction_natureelements_nature_element_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements
    ADD CONSTRAINT diagnose_prediction_natureelements_nature_element_id_fkey FOREIGN KEY (nature_element_id) REFERENCES public.diagnose_naturalelements(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5015 (class 2606 OID 47274)
-- Name: diagnose_prediction_natureelements diagnose_prediction_natureelements_prediction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements
    ADD CONSTRAINT diagnose_prediction_natureelements_prediction_id_fkey FOREIGN KEY (prediction_id) REFERENCES public.diagnose_predictions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5012 (class 2606 OID 47269)
-- Name: diagnose_predictions diagnose_predictions_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions
    ADD CONSTRAINT diagnose_predictions_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.diagnose_areas(id) ON UPDATE CASCADE;


--
-- TOC entry 5013 (class 2606 OID 47264)
-- Name: diagnose_predictions diagnose_predictions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions
    ADD CONSTRAINT diagnose_predictions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


-- Completed on 2025-03-02 15:32:26

--
-- PostgreSQL database dump complete
--

