--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2025-09-28 17:09:14

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
-- TOC entry 4968 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 873 (class 1247 OID 296827)
-- Name: enum_diagnose_areas_area_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_diagnose_areas_area_type AS ENUM (
    'oyster',
    'cobia'
);


ALTER TYPE public.enum_diagnose_areas_area_type OWNER TO postgres;

--
-- TOC entry 876 (class 1247 OID 296832)
-- Name: enum_users_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_users_role AS ENUM (
    'expert',
    'manager',
    'admin'
);


ALTER TYPE public.enum_users_role OWNER TO postgres;

--
-- TOC entry 879 (class 1247 OID 296840)
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
-- TOC entry 4969 (class 0 OID 0)
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
    name character varying(255) NOT NULL,
    description text,
    unit character varying(255),
    category character varying(255)
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
-- TOC entry 4970 (class 0 OID 0)
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
-- TOC entry 4971 (class 0 OID 0)
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
-- TOC entry 4972 (class 0 OID 0)
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
-- TOC entry 232 (class 1259 OID 305001)
-- Name: email_subscriptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_subscriptions (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    area_id integer NOT NULL,
    is_active boolean DEFAULT true,
    unsubscribe_token character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.email_subscriptions OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 305000)
-- Name: email_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.email_subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.email_subscriptions_id_seq OWNER TO postgres;

--
-- TOC entry 4973 (class 0 OID 0)
-- Dependencies: 231
-- Name: email_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.email_subscriptions_id_seq OWNED BY public.email_subscriptions.id;


--
-- TOC entry 234 (class 1259 OID 305018)
-- Name: otps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.otps (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    area_id integer NOT NULL,
    otp_code character varying(6) NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    is_used boolean DEFAULT false,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.otps OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 305017)
-- Name: otps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.otps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.otps_id_seq OWNER TO postgres;

--
-- TOC entry 4974 (class 0 OID 0)
-- Dependencies: 233
-- Name: otps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.otps_id_seq OWNED BY public.otps.id;


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
-- TOC entry 4975 (class 0 OID 0)
-- Dependencies: 228
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4757 (class 2604 OID 296890)
-- Name: diagnose_areas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_areas ALTER COLUMN id SET DEFAULT nextval('public.diagnose_areas_id_seq'::regclass);


--
-- TOC entry 4758 (class 2604 OID 296891)
-- Name: diagnose_naturalelements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_naturalelements ALTER COLUMN id SET DEFAULT nextval('public.diagnose_naturalelements_id_seq'::regclass);


--
-- TOC entry 4759 (class 2604 OID 296892)
-- Name: diagnose_prediction_natureelements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements ALTER COLUMN id SET DEFAULT nextval('public.diagnose_prediction_natureelements_id_seq'::regclass);


--
-- TOC entry 4760 (class 2604 OID 296893)
-- Name: diagnose_predictions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions ALTER COLUMN id SET DEFAULT nextval('public.diagnose_predictions_id_seq'::regclass);


--
-- TOC entry 4763 (class 2604 OID 305004)
-- Name: email_subscriptions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.email_subscriptions_id_seq'::regclass);


--
-- TOC entry 4765 (class 2604 OID 305021)
-- Name: otps id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otps ALTER COLUMN id SET DEFAULT nextval('public.otps_id_seq'::regclass);


--
-- TOC entry 4761 (class 2604 OID 296895)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4946 (class 0 OID 296845)
-- Dependencies: 218
-- Data for Name: SequelizeMeta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SequelizeMeta" (name) FROM stdin;
20250115000000-add-description-to-naturalelements.js
\.


--
-- TOC entry 4947 (class 0 OID 296848)
-- Dependencies: 219
-- Data for Name: diagnose_areas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnose_areas (id, name, latitude, longitude, area, area_type, province, district) FROM stdin;
49	adasd12121	10.762495303939643	106.66027620776322	1000	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
50	Khu vực B	10.763728494588353	106.66367167890975	1000	cobia	fdca33cf-6b24-409b-9d07-46efb37051f5	40ebf59b-c17e-43a6-a2cd-1f8c77daae92
\.


--
-- TOC entry 4949 (class 0 OID 296853)
-- Dependencies: 221
-- Data for Name: diagnose_naturalelements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnose_naturalelements (id, name, description, unit, category) FROM stdin;
8	R_PO4	Reactive Phosphorus - Phospho phản ứng, một dạng phospho có thể được thực vật thủy sinh sử dụng trực tiếp	mg/L	Nutrients
9	O2Sat	Oxygen Saturation - Độ bão hòa oxy trong nước, tỷ lệ phần trăm oxy hòa tan so với khả năng hòa tan tối đa	%	Water Quality
10	O2ml_L	Oxygen Concentration - Nồng độ oxy hòa tan trong nước, đo bằng ml oxy trên 1 lít nước	ml/L	Water Quality
11	STheta	Potential Temperature - Nhiệt độ tiềm năng, nhiệt độ nước sau khi điều chỉnh áp suất về mực nước biển	°C	Physical Properties
12	Salnty	Salinity - Độ mặn của nước, tổng lượng muối hòa tan trong nước	PSU (Practical Salinity Units)	Physical Properties
13	R_DYNHT	Dynamic Height - Chiều cao động lực, đo sự chênh lệch mực nước do dòng chảy	m	Physical Properties
14	T_degC	Temperature - Nhiệt độ nước, ảnh hưởng đến tốc độ phản ứng sinh hóa và sự phát triển của sinh vật	°C	Physical Properties
15	R_Depth	Depth - Độ sâu của nước, khoảng cách từ mặt nước đến đáy	m	Physical Properties
16	Distance	Distance from Shore - Khoảng cách từ bờ biển, ảnh hưởng đến điều kiện môi trường	km	Location
17	Wind_Spd	Wind Speed - Tốc độ gió, ảnh hưởng đến sóng và dòng chảy nước	m/s	Atmospheric
18	Wave_Ht	Wave Height - Chiều cao sóng, đo từ đáy đến đỉnh sóng	m	Atmospheric
19	Wave_Prd	Wave Period - Chu kỳ sóng, thời gian giữa hai đỉnh sóng liên tiếp	s	Atmospheric
20	IntChl	Integrated Chlorophyll - Chlorophyll tích hợp, tổng lượng chlorophyll trong cột nước, chỉ thị mật độ tảo	mg/m²	Biological
21	Dry_T	Dry Temperature - Nhiệt độ khô, nhiệt độ không khí không có độ ẩm	°C	Atmospheric
\.


--
-- TOC entry 4951 (class 0 OID 296857)
-- Dependencies: 223
-- Data for Name: diagnose_prediction_natureelements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnose_prediction_natureelements (id, prediction_id, nature_element_id, value) FROM stdin;
435	48	8	1
436	48	9	1
437	48	10	1
438	48	11	1
439	48	12	1
440	48	13	1
441	48	14	1
442	48	15	1
443	48	16	1
444	48	17	1
445	48	18	1
446	48	19	1
447	48	20	1
448	48	21	1
449	49	8	2
450	49	9	2
451	49	10	2
452	49	11	2
453	49	12	2
454	49	13	2
455	49	14	2
456	49	15	2
457	49	16	2
458	49	17	2
459	49	18	2
460	49	19	2
461	49	20	2
462	49	21	1
463	50	8	1
464	50	9	1
465	50	10	1
466	50	11	1
467	50	12	1
468	50	13	1
469	50	14	1
470	50	15	1
471	50	16	1
472	50	17	1
473	50	18	1
474	50	19	1
475	50	20	1
476	50	21	1
477	51	8	2
478	51	9	2
479	51	10	2
480	51	11	2
481	51	12	2
482	51	13	2
483	51	14	2
484	51	15	2
485	51	16	2
486	51	17	2
487	51	18	2
488	51	19	2
489	51	20	2
490	51	21	1
491	52	8	1
492	52	9	1
493	52	10	1
494	52	11	1
495	52	12	1
496	52	13	1
497	52	14	1
498	52	15	1
499	52	16	1
500	52	17	1
501	52	18	1
502	52	19	1
503	52	20	1
504	52	21	1
505	53	8	111
506	53	9	1
507	53	10	1
508	53	11	1
509	53	12	1
510	53	13	1
511	53	14	1
512	53	15	1
513	53	16	1
514	53	17	1
515	53	18	1
516	53	19	1
517	53	20	1
518	53	21	1
\.


--
-- TOC entry 4953 (class 0 OID 296861)
-- Dependencies: 225
-- Data for Name: diagnose_predictions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnose_predictions (id, user_id, area_id, prediction_text, "createdAt", "updatedAt") FROM stdin;
48	5	49	0	1970-01-01 07:00:00.001+07	2025-09-21 19:32:43.868+07
49	5	49	0	1970-01-01 07:00:00.001+07	2025-09-21 19:32:44.321+07
50	5	49	-1	1970-01-01 07:00:00.001+07	2025-09-21 19:50:57.424+07
51	5	49	-1	1970-01-01 07:00:00.001+07	2025-09-21 19:50:58.269+07
52	5	49	6	2025-09-21 20:25:02.255+07	2025-09-21 20:25:02.259+07
53	5	49	-1	2025-09-21 20:47:28.356+07	2025-09-21 20:47:28.364+07
\.


--
-- TOC entry 4958 (class 0 OID 296951)
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
-- TOC entry 4960 (class 0 OID 305001)
-- Dependencies: 232
-- Data for Name: email_subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_subscriptions (id, email, area_id, is_active, unsubscribe_token, created_at, updated_at) FROM stdin;
5	nghiem.ld215102@sis.hust.edu.vn	49	t	a11c44d0229564946b48d540b14c7f161359707d866d40d9dec08a2a16fe4d85	2025-09-17 02:52:25.94+07	2025-09-17 02:52:25.941+07
6	nghiem.eo.bua.18@gmail.com	49	t	cdb19ffa9592a555a11962d4a2e5add1c220eabc603c1aac177de9f28055bc77	2025-09-21 20:38:50.434+07	2025-09-21 20:38:50.435+07
\.


--
-- TOC entry 4962 (class 0 OID 305018)
-- Dependencies: 234
-- Data for Name: otps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.otps (id, email, area_id, otp_code, expires_at, is_used, created_at, updated_at) FROM stdin;
2	nghiem.ld215102@sis.hust.edu.vn	49	923330	2025-09-17 02:57:01.449+07	t	2025-09-17 02:52:01.495+07	2025-09-17 02:52:25.913+07
3	nghiem.eo.bua.18@gmail.com	49	858264	2025-09-21 20:43:11.949+07	t	2025-09-21 20:38:11.976+07	2025-09-21 20:38:50.415+07
\.


--
-- TOC entry 4957 (class 0 OID 296946)
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
-- TOC entry 4955 (class 0 OID 296882)
-- Dependencies: 227
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password, role, email, address, phone, status, province, district) FROM stdin;
5	nghiem.eo.bua.18	$2b$10$Wuk6i5.psEePYk78HjdrGed2B8DcXOxUDG292OzhV6BKnUBBgtZza	expert	nghiem.eo.bua.1@gmail.com	82 Ngo Quyen 	0111111111	active	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
3	administrator	$2b$10$8drYopD10fl9OyxWHCybXeDccD4h2sZa4v2sx5FmDP/RBLfYhv7LO	admin	administrator@gmail.com	82 Ngo Quyen 	0111111111	active	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
4	manager1	$2b$10$yvYCht8x1OP3WQRUJlTgWOKoCU5rux22RaK9VwVChWJJzU7O9Rsk.	expert	manager@gmail.com	82 Ngo Quyen.St	0111111113	active	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
6	nghiem1	$2b$10$0jw8EJoMR7wbpyYOeca16OLA9tx.ege84z/FCbLtqMr5zoHTGjDbi	manager	nghiem1@gmail.com	82 Ngo Quyen 	0111111114	active	f851f9a1-330b-4d29-98ae-f4092e7e7f70	\N
9	nghiem.eo.buaa.18	$2b$10$P3Kg43M2yHFe/0jJskylwubl73Br438uLHOWQpS3eDgDdUvYYT6JC	manager	nghiem.eo.buaa.18@gmail.com	82 Ngo Quyen.St	0354685515	active	f851f9a1-330b-4d29-98ae-f4092e7e7f70	\N
10	adadad	$2b$10$wX1Iw9z1VDhlbfvFJMtrIel8iKOUha0BpVwHhTbAVe8Qi4JXbBk5.	manager	adadad@caa.com	ewqewqe	01212121	active	fb7e3341-2d65-44ba-868a-1c89c85e36a1	\N
11	adadaad	$2b$10$iLrbOvKjNLNIAmTHI9DsFewPdmRPTT/WJgpl7hp9I.b3p2KSYbhk2	manager	adadaad@caa.com	ewqewqe2	012121211	active	fb7e3341-2d65-44ba-868a-1c89c85e36a1	e1de6f8d-e46b-4e7a-b0d3-09bb7ae0b7e9
8	nghiem2	$2b$10$8AffzeFiRtdFeml3W5RRyOPg4w4/2RgRdlbX56Yc9.Vop6fy16mGi	manager	nghiem2@gmail.com	82 Ngo Quyen 	0111111112	active	f851f9a1-330b-4d29-98ae-f4092e7e7f70	40ebf59b-c17e-43a6-a2cd-1f8c77daae92
12	abcdef	$2b$10$URhuGKaLJylqnzbWSfELJuPQ4jIeIXBqx4f0Us5ml/Ks9k0UuKFcO	manager	abcdef@gmail.com	82 Ngo Quyen	034343333	active	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
13	administrator1	$2b$10$J4bWMh.Qn.x8otvNDZ6gEOZLTYNuayUJ3cYJbAcoEX6MSnuN.73pa	manager	administrator1@gmail.com	82 Ngo Quyen.St	0354685510	active	fdca33cf-6b24-409b-9d07-46efb37051f5	e72ee733-77ab-4f3b-99a2-9963707d4c0d
\.


--
-- TOC entry 4976 (class 0 OID 0)
-- Dependencies: 220
-- Name: diagnose_areas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_areas_id_seq', 50, true);


--
-- TOC entry 4977 (class 0 OID 0)
-- Dependencies: 222
-- Name: diagnose_naturalelements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_naturalelements_id_seq', 21, true);


--
-- TOC entry 4978 (class 0 OID 0)
-- Dependencies: 224
-- Name: diagnose_prediction_natureelements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_prediction_natureelements_id_seq', 518, true);


--
-- TOC entry 4979 (class 0 OID 0)
-- Dependencies: 226
-- Name: diagnose_predictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_predictions_id_seq', 53, true);


--
-- TOC entry 4980 (class 0 OID 0)
-- Dependencies: 231
-- Name: email_subscriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.email_subscriptions_id_seq', 6, true);


--
-- TOC entry 4981 (class 0 OID 0)
-- Dependencies: 233
-- Name: otps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.otps_id_seq', 3, true);


--
-- TOC entry 4982 (class 0 OID 0)
-- Dependencies: 228
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 13, true);


--
-- TOC entry 4770 (class 2606 OID 296897)
-- Name: SequelizeMeta SequelizeMeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SequelizeMeta"
    ADD CONSTRAINT "SequelizeMeta_pkey" PRIMARY KEY (name);


--
-- TOC entry 4772 (class 2606 OID 296899)
-- Name: diagnose_areas diagnose_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_areas
    ADD CONSTRAINT diagnose_areas_pkey PRIMARY KEY (id);


--
-- TOC entry 4774 (class 2606 OID 296901)
-- Name: diagnose_naturalelements diagnose_naturalelements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_naturalelements
    ADD CONSTRAINT diagnose_naturalelements_pkey PRIMARY KEY (id);


--
-- TOC entry 4776 (class 2606 OID 296903)
-- Name: diagnose_prediction_natureelements diagnose_prediction_natureelements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements
    ADD CONSTRAINT diagnose_prediction_natureelements_pkey PRIMARY KEY (id);


--
-- TOC entry 4778 (class 2606 OID 296905)
-- Name: diagnose_predictions diagnose_predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions
    ADD CONSTRAINT diagnose_predictions_pkey PRIMARY KEY (id);


--
-- TOC entry 4786 (class 2606 OID 296955)
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- TOC entry 4788 (class 2606 OID 305009)
-- Name: email_subscriptions email_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_subscriptions
    ADD CONSTRAINT email_subscriptions_pkey PRIMARY KEY (id);


--
-- TOC entry 4790 (class 2606 OID 305011)
-- Name: email_subscriptions email_subscriptions_unsubscribe_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_subscriptions
    ADD CONSTRAINT email_subscriptions_unsubscribe_token_key UNIQUE (unsubscribe_token);


--
-- TOC entry 4792 (class 2606 OID 305024)
-- Name: otps otps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otps
    ADD CONSTRAINT otps_pkey PRIMARY KEY (id);


--
-- TOC entry 4784 (class 2606 OID 296950)
-- Name: provinces provinces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provinces
    ADD CONSTRAINT provinces_pkey PRIMARY KEY (id);


--
-- TOC entry 4780 (class 2606 OID 296913)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4782 (class 2606 OID 296915)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 4795 (class 2606 OID 296921)
-- Name: diagnose_prediction_natureelements diagnose_prediction_natureelements_nature_element_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements
    ADD CONSTRAINT diagnose_prediction_natureelements_nature_element_id_fkey FOREIGN KEY (nature_element_id) REFERENCES public.diagnose_naturalelements(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4796 (class 2606 OID 296926)
-- Name: diagnose_prediction_natureelements diagnose_prediction_natureelements_prediction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements
    ADD CONSTRAINT diagnose_prediction_natureelements_prediction_id_fkey FOREIGN KEY (prediction_id) REFERENCES public.diagnose_predictions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4797 (class 2606 OID 296931)
-- Name: diagnose_predictions diagnose_predictions_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions
    ADD CONSTRAINT diagnose_predictions_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.diagnose_areas(id) ON UPDATE CASCADE;


--
-- TOC entry 4798 (class 2606 OID 296936)
-- Name: diagnose_predictions diagnose_predictions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions
    ADD CONSTRAINT diagnose_predictions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE;


--
-- TOC entry 4799 (class 2606 OID 296956)
-- Name: districts districts_province_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_province_id_fkey FOREIGN KEY (province_id) REFERENCES public.provinces(id);


--
-- TOC entry 4800 (class 2606 OID 305012)
-- Name: email_subscriptions email_subscriptions_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_subscriptions
    ADD CONSTRAINT email_subscriptions_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.diagnose_areas(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4793 (class 2606 OID 296966)
-- Name: diagnose_areas fk_district; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_areas
    ADD CONSTRAINT fk_district FOREIGN KEY (district) REFERENCES public.districts(id);


--
-- TOC entry 4794 (class 2606 OID 296961)
-- Name: diagnose_areas fk_province; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_areas
    ADD CONSTRAINT fk_province FOREIGN KEY (province) REFERENCES public.provinces(id);


-- Completed on 2025-09-28 17:09:14

--
-- PostgreSQL database dump complete
--

