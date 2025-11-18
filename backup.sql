--
-- PostgreSQL database dump
--

-- Dumped from database version 17.0
-- Dumped by pg_dump version 17.0

-- Started on 2025-11-08 01:50:45

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
-- TOC entry 7 (class 2615 OID 305027)
-- Name: pgboss; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pgboss;


ALTER SCHEMA pgboss OWNER TO postgres;

--
-- TOC entry 2 (class 3079 OID 296815)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- TOC entry 5034 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 921 (class 1247 OID 305034)
-- Name: job_state; Type: TYPE; Schema: pgboss; Owner: postgres
--

CREATE TYPE pgboss.job_state AS ENUM (
    'created',
    'retry',
    'active',
    'completed',
    'expired',
    'cancelled',
    'failed'
);


ALTER TYPE pgboss.job_state OWNER TO postgres;

--
-- TOC entry 879 (class 1247 OID 296827)
-- Name: enum_diagnose_areas_area_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_diagnose_areas_area_type AS ENUM (
    'oyster',
    'cobia'
);


ALTER TYPE public.enum_diagnose_areas_area_type OWNER TO postgres;

--
-- TOC entry 882 (class 1247 OID 296832)
-- Name: enum_users_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.enum_users_role AS ENUM (
    'expert',
    'manager',
    'admin'
);


ALTER TYPE public.enum_users_role OWNER TO postgres;

--
-- TOC entry 885 (class 1247 OID 296840)
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
-- TOC entry 238 (class 1259 OID 305068)
-- Name: archive; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.archive (
    id uuid NOT NULL,
    name text NOT NULL,
    priority integer NOT NULL,
    data jsonb,
    state pgboss.job_state NOT NULL,
    retrylimit integer NOT NULL,
    retrycount integer NOT NULL,
    retrydelay integer NOT NULL,
    retrybackoff boolean NOT NULL,
    startafter timestamp with time zone NOT NULL,
    startedon timestamp with time zone,
    singletonkey text,
    singletonon timestamp without time zone,
    expirein interval NOT NULL,
    createdon timestamp with time zone NOT NULL,
    completedon timestamp with time zone,
    keepuntil timestamp with time zone NOT NULL,
    on_complete boolean NOT NULL,
    output jsonb,
    archivedon timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.archive OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 305049)
-- Name: job; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.job (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    data jsonb,
    state pgboss.job_state DEFAULT 'created'::pgboss.job_state NOT NULL,
    retrylimit integer DEFAULT 0 NOT NULL,
    retrycount integer DEFAULT 0 NOT NULL,
    retrydelay integer DEFAULT 0 NOT NULL,
    retrybackoff boolean DEFAULT false NOT NULL,
    startafter timestamp with time zone DEFAULT now() NOT NULL,
    startedon timestamp with time zone,
    singletonkey text,
    singletonon timestamp without time zone,
    expirein interval DEFAULT '00:15:00'::interval NOT NULL,
    createdon timestamp with time zone DEFAULT now() NOT NULL,
    completedon timestamp with time zone,
    keepuntil timestamp with time zone DEFAULT (now() + '14 days'::interval) NOT NULL,
    on_complete boolean DEFAULT false NOT NULL,
    output jsonb
);


ALTER TABLE pgboss.job OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 305073)
-- Name: schedule; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.schedule (
    name text NOT NULL,
    cron text NOT NULL,
    timezone text,
    data jsonb,
    options jsonb,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.schedule OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 305082)
-- Name: subscription; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.subscription (
    event text NOT NULL,
    name text NOT NULL,
    created_on timestamp with time zone DEFAULT now() NOT NULL,
    updated_on timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE pgboss.subscription OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 305028)
-- Name: version; Type: TABLE; Schema: pgboss; Owner: postgres
--

CREATE TABLE pgboss.version (
    version integer NOT NULL,
    maintained_on timestamp with time zone,
    cron_on timestamp with time zone
);


ALTER TABLE pgboss.version OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 296845)
-- Name: SequelizeMeta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."SequelizeMeta" (
    name character varying(255) NOT NULL
);


ALTER TABLE public."SequelizeMeta" OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 296848)
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
-- TOC entry 221 (class 1259 OID 296852)
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
-- TOC entry 5035 (class 0 OID 0)
-- Dependencies: 221
-- Name: diagnose_areas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diagnose_areas_id_seq OWNED BY public.diagnose_areas.id;


--
-- TOC entry 222 (class 1259 OID 296853)
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
-- TOC entry 223 (class 1259 OID 296856)
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
-- TOC entry 5036 (class 0 OID 0)
-- Dependencies: 223
-- Name: diagnose_naturalelements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diagnose_naturalelements_id_seq OWNED BY public.diagnose_naturalelements.id;


--
-- TOC entry 224 (class 1259 OID 296857)
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
-- TOC entry 225 (class 1259 OID 296860)
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
-- TOC entry 5037 (class 0 OID 0)
-- Dependencies: 225
-- Name: diagnose_prediction_natureelements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diagnose_prediction_natureelements_id_seq OWNED BY public.diagnose_prediction_natureelements.id;


--
-- TOC entry 226 (class 1259 OID 296861)
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
-- TOC entry 227 (class 1259 OID 296866)
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
-- TOC entry 5038 (class 0 OID 0)
-- Dependencies: 227
-- Name: diagnose_predictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diagnose_predictions_id_seq OWNED BY public.diagnose_predictions.id;


--
-- TOC entry 231 (class 1259 OID 296951)
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
-- TOC entry 233 (class 1259 OID 305001)
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
-- TOC entry 232 (class 1259 OID 305000)
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
-- TOC entry 5039 (class 0 OID 0)
-- Dependencies: 232
-- Name: email_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.email_subscriptions_id_seq OWNED BY public.email_subscriptions.id;


--
-- TOC entry 235 (class 1259 OID 305018)
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
-- TOC entry 234 (class 1259 OID 305017)
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
-- TOC entry 5040 (class 0 OID 0)
-- Dependencies: 234
-- Name: otps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.otps_id_seq OWNED BY public.otps.id;


--
-- TOC entry 230 (class 1259 OID 296946)
-- Name: provinces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.provinces (
    id uuid NOT NULL,
    name character varying(100) NOT NULL,
    central_meridian double precision
);


ALTER TABLE public.provinces OWNER TO postgres;

--
-- TOC entry 5041 (class 0 OID 0)
-- Dependencies: 230
-- Name: COLUMN provinces.central_meridian; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.provinces.central_meridian IS 'Kinh tuyến trục VN2000 (độ)';


--
-- TOC entry 228 (class 1259 OID 296882)
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
-- TOC entry 229 (class 1259 OID 296889)
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
-- TOC entry 5042 (class 0 OID 0)
-- Dependencies: 229
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4781 (class 2604 OID 296890)
-- Name: diagnose_areas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_areas ALTER COLUMN id SET DEFAULT nextval('public.diagnose_areas_id_seq'::regclass);


--
-- TOC entry 4782 (class 2604 OID 296891)
-- Name: diagnose_naturalelements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_naturalelements ALTER COLUMN id SET DEFAULT nextval('public.diagnose_naturalelements_id_seq'::regclass);


--
-- TOC entry 4783 (class 2604 OID 296892)
-- Name: diagnose_prediction_natureelements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements ALTER COLUMN id SET DEFAULT nextval('public.diagnose_prediction_natureelements_id_seq'::regclass);


--
-- TOC entry 4784 (class 2604 OID 296893)
-- Name: diagnose_predictions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions ALTER COLUMN id SET DEFAULT nextval('public.diagnose_predictions_id_seq'::regclass);


--
-- TOC entry 4787 (class 2604 OID 305004)
-- Name: email_subscriptions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.email_subscriptions_id_seq'::regclass);


--
-- TOC entry 4789 (class 2604 OID 305021)
-- Name: otps id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otps ALTER COLUMN id SET DEFAULT nextval('public.otps_id_seq'::regclass);


--
-- TOC entry 4785 (class 2604 OID 296895)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 5026 (class 0 OID 305068)
-- Dependencies: 238
-- Data for Name: archive; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.archive (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output, archivedon) FROM stdin;
3663117e-6441-4f26-ae78-993c526ac7c6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 01:44:01.37334+07	2025-11-04 01:44:01.407981+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 01:44:01.37334+07	2025-11-04 01:44:01.468686+07	2025-11-04 01:52:01.37334+07	f	\N	2025-11-04 22:27:01.344506+07
9d4c2d94-b05d-468a-9ce8-4a452b1450c7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 02:04:01.064403+07	2025-11-04 02:04:04.174388+07	\N	2025-11-03 19:04:00	00:15:00	2025-11-04 02:03:04.064403+07	2025-11-04 02:04:04.19017+07	2025-11-04 02:05:01.064403+07	f	\N	2025-11-04 22:27:01.344506+07
4f168856-b822-4297-bdda-41f68db2a511	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 02:03:23.316304+07	2025-11-04 02:04:23.330353+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 02:01:23.316304+07	2025-11-04 02:04:23.445112+07	2025-11-04 02:11:23.316304+07	f	\N	2025-11-04 22:27:01.344506+07
4119c933-cc12-4d76-bfcc-3fb138801a51	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:44:01.912305+07	2025-11-04 01:44:05.65425+07	\N	2025-11-03 18:44:00	00:15:00	2025-11-04 01:44:01.912305+07	2025-11-04 01:44:05.67129+07	2025-11-04 01:45:01.912305+07	f	\N	2025-11-04 22:27:01.344506+07
5cae2c8e-12c5-43bd-9566-4aae26f7762b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:45:01.669036+07	2025-11-04 01:45:01.766506+07	\N	2025-11-03 18:45:00	00:15:00	2025-11-04 01:44:05.669036+07	2025-11-04 01:45:01.996441+07	2025-11-04 01:46:01.669036+07	f	\N	2025-11-04 22:27:01.344506+07
c9a2849a-a3ca-4a96-a215-2a002067ced8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 02:05:01.183601+07	2025-11-04 02:05:04.301708+07	\N	2025-11-03 19:05:00	00:15:00	2025-11-04 02:04:04.183601+07	2025-11-04 02:05:04.312041+07	2025-11-04 02:06:01.183601+07	f	\N	2025-11-04 22:27:01.344506+07
18838236-c152-4d93-b0f9-4b84c4b9d146	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:46:01.964178+07	2025-11-04 01:46:05.884616+07	\N	2025-11-03 18:46:00	00:15:00	2025-11-04 01:45:01.964178+07	2025-11-04 01:46:05.910219+07	2025-11-04 01:47:01.964178+07	f	\N	2025-11-04 22:27:01.344506+07
88346b7c-e671-4330-aacc-0e0635ca7eb2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 01:46:01.52717+07	2025-11-04 01:47:01.433702+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 01:44:01.52717+07	2025-11-04 01:47:01.652041+07	2025-11-04 01:54:01.52717+07	f	\N	2025-11-04 22:27:01.344506+07
8ae2b95a-a909-4c47-953e-4d567d11fefa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 02:06:01.309756+07	2025-11-04 02:06:04.429628+07	\N	2025-11-03 19:06:00	00:15:00	2025-11-04 02:05:04.309756+07	2025-11-04 02:06:04.517861+07	2025-11-04 02:07:01.309756+07	f	\N	2025-11-04 22:27:01.344506+07
c2544ace-93fb-404d-bec3-1a18b94a0af5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:47:01.995542+07	2025-11-04 01:47:02.756998+07	\N	2025-11-03 18:47:00	00:15:00	2025-11-04 01:46:01.995542+07	2025-11-04 01:47:02.84074+07	2025-11-04 01:48:01.995542+07	f	\N	2025-11-04 22:27:01.344506+07
e56d964b-7483-4bf3-9d6f-d64c98d1b23f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 02:06:31.599067+07	2025-11-04 02:06:31.632492+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 02:06:31.599067+07	2025-11-04 02:06:31.725466+07	2025-11-04 02:14:31.599067+07	f	\N	2025-11-04 22:27:01.344506+07
22539e02-bb0c-4824-ae69-d725f201f1dc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:48:01.835898+07	2025-11-04 01:48:02.139749+07	\N	2025-11-03 18:48:00	00:15:00	2025-11-04 01:47:02.835898+07	2025-11-04 01:48:02.168278+07	2025-11-04 01:49:01.835898+07	f	\N	2025-11-04 22:27:01.344506+07
38a2c720-903a-43f1-b88e-5445c86058fd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:49:01.164205+07	2025-11-04 01:49:02.243222+07	\N	2025-11-03 18:49:00	00:15:00	2025-11-04 01:48:02.164205+07	2025-11-04 01:49:02.306631+07	2025-11-04 01:50:01.164205+07	f	\N	2025-11-04 22:27:01.344506+07
8316f168-2349-4a4e-a45a-9bcb16cd4f84	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 02:07:01.480171+07	2025-11-04 02:07:03.973651+07	\N	2025-11-03 19:07:00	00:15:00	2025-11-04 02:06:04.480171+07	2025-11-04 02:07:04.003926+07	2025-11-04 02:08:01.480171+07	f	\N	2025-11-04 22:27:01.344506+07
3ce2f370-a540-4e8e-b389-7eeb0a1d09e9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 01:49:01.697629+07	2025-11-04 01:50:01.460304+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 01:47:01.697629+07	2025-11-04 01:50:01.519256+07	2025-11-04 01:57:01.697629+07	f	\N	2025-11-04 22:27:01.344506+07
93547bdd-5ff1-4bcb-8122-a18dfaf22525	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 02:08:01.99917+07	2025-11-04 02:08:04.100391+07	\N	2025-11-03 19:08:00	00:15:00	2025-11-04 02:07:03.99917+07	2025-11-04 02:08:04.120082+07	2025-11-04 02:09:01.99917+07	f	\N	2025-11-04 22:27:01.344506+07
582d743a-2b8f-4222-863b-8277c45bf398	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:50:01.265561+07	2025-11-04 01:50:02.355726+07	\N	2025-11-03 18:50:00	00:15:00	2025-11-04 01:49:02.265561+07	2025-11-04 01:50:02.383928+07	2025-11-04 01:51:01.265561+07	f	\N	2025-11-04 22:27:01.344506+07
723db0c7-ba22-46d5-9134-165521a68b29	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:51:01.379872+07	2025-11-04 01:51:02.506172+07	\N	2025-11-03 18:51:00	00:15:00	2025-11-04 01:50:02.379872+07	2025-11-04 01:51:02.550362+07	2025-11-04 01:52:01.379872+07	f	\N	2025-11-04 22:27:01.344506+07
786c140c-ce0e-4d15-a2ce-31bf4c5023bb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 02:09:01.115356+07	2025-11-04 02:09:04.205675+07	\N	2025-11-03 19:09:00	00:15:00	2025-11-04 02:08:04.115356+07	2025-11-04 02:09:04.227077+07	2025-11-04 02:10:01.115356+07	f	\N	2025-11-04 22:27:01.344506+07
8da15b22-c188-4fcc-b526-9d10d4aa17ed	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 01:52:01.526853+07	2025-11-04 01:52:01.875308+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 01:50:01.526853+07	2025-11-04 01:52:03.84033+07	2025-11-04 02:00:01.526853+07	f	\N	2025-11-04 22:27:01.344506+07
ba3783ab-8ab7-4ee1-9811-e536689e3ca6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 02:08:31.734632+07	2025-11-04 02:09:31.653089+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 02:06:31.734632+07	2025-11-04 02:09:31.681312+07	2025-11-04 02:16:31.734632+07	f	\N	2025-11-04 22:27:01.344506+07
dd147f9f-4d04-49ac-8cc5-e131f7cc6f42	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:52:01.544082+07	2025-11-04 01:52:04.485961+07	\N	2025-11-03 18:52:00	00:15:00	2025-11-04 01:51:02.544082+07	2025-11-04 01:52:04.630728+07	2025-11-04 01:53:01.544082+07	f	\N	2025-11-04 22:27:01.344506+07
4db43faf-ac1e-492e-b6c9-fdc125cac734	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:53:01.607782+07	2025-11-04 01:53:03.967248+07	\N	2025-11-03 18:53:00	00:15:00	2025-11-04 01:52:04.607782+07	2025-11-04 01:53:04.008553+07	2025-11-04 01:54:01.607782+07	f	\N	2025-11-04 22:27:01.344506+07
50464f0f-97c2-4cb9-b71d-e42271bed976	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 02:10:01.220661+07	2025-11-04 02:10:04.319255+07	\N	2025-11-03 19:10:00	00:15:00	2025-11-04 02:09:04.220661+07	2025-11-04 02:10:04.335272+07	2025-11-04 02:11:01.220661+07	f	\N	2025-11-04 22:27:01.344506+07
5a41c00a-d826-461d-89a3-75f83825e34c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:54:02.00286+07	2025-11-04 01:54:04.112981+07	\N	2025-11-03 18:54:00	00:15:00	2025-11-04 01:53:04.00286+07	2025-11-04 01:54:04.468068+07	2025-11-04 01:55:02.00286+07	f	\N	2025-11-04 22:27:01.344506+07
2e0ff63d-e0a6-4c0c-a598-1c3f2418b156	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 01:54:03.857221+07	2025-11-04 01:55:01.910089+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 01:52:03.857221+07	2025-11-04 01:55:01.943203+07	2025-11-04 02:02:03.857221+07	f	\N	2025-11-04 22:27:01.344506+07
0fc446c5-3e3f-418e-9c59-1b992def7cb4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 02:11:01.3306+07	2025-11-04 02:11:04.450327+07	\N	2025-11-03 19:11:00	00:15:00	2025-11-04 02:10:04.3306+07	2025-11-04 02:11:04.46252+07	2025-11-04 02:12:01.3306+07	f	\N	2025-11-04 22:27:01.344506+07
a8e06fd6-b763-47a6-a07f-e5f4e50d4ae1	__pgboss__cron	0	\N	created	2	0	0	f	2025-11-04 02:13:01.623574+07	\N	\N	2025-11-03 19:13:00	00:15:00	2025-11-04 02:12:04.623574+07	\N	2025-11-04 02:14:01.623574+07	f	\N	2025-11-04 22:27:01.344506+07
9882fc74-68b6-461e-9e74-c983a156b8b5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:55:01.19692+07	2025-11-04 01:55:04.240811+07	\N	2025-11-03 18:55:00	00:15:00	2025-11-04 01:54:04.19692+07	2025-11-04 01:55:04.251801+07	2025-11-04 01:56:01.19692+07	f	\N	2025-11-04 22:27:01.344506+07
8f9a1cb5-4afb-4d1d-9438-f49c3de3d8bf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 02:12:01.45909+07	2025-11-04 02:12:04.594515+07	\N	2025-11-03 19:12:00	00:15:00	2025-11-04 02:11:04.45909+07	2025-11-04 02:12:04.634025+07	2025-11-04 02:13:01.45909+07	f	\N	2025-11-04 22:27:01.344506+07
5cdcdd5d-1443-49c3-9917-76e2469d3025	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:56:01.24935+07	2025-11-04 01:56:04.424099+07	\N	2025-11-03 18:56:00	00:15:00	2025-11-04 01:55:04.24935+07	2025-11-04 01:56:04.610323+07	2025-11-04 01:57:01.24935+07	f	\N	2025-11-04 22:27:01.344506+07
1ab69ef7-37b8-429e-805b-5cfc430a8018	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:57:01.570576+07	2025-11-04 01:57:04.544753+07	\N	2025-11-03 18:57:00	00:15:00	2025-11-04 01:56:04.570576+07	2025-11-04 01:57:04.570143+07	2025-11-04 01:58:01.570576+07	f	\N	2025-11-04 22:27:01.344506+07
4129ecf0-019f-4f77-8710-d7c1d2677651	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 01:58:23.231399+07	2025-11-04 01:58:23.257155+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 01:58:23.231399+07	2025-11-04 01:58:23.320284+07	2025-11-04 02:06:23.231399+07	f	\N	2025-11-04 22:27:01.344506+07
2a4e12f7-5a3a-4327-8b99-42e78c1b9442	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:58:01.564828+07	2025-11-04 01:58:23.492194+07	\N	2025-11-03 18:58:00	00:15:00	2025-11-04 01:57:04.564828+07	2025-11-04 01:58:23.530763+07	2025-11-04 01:59:01.564828+07	f	\N	2025-11-04 22:27:01.344506+07
4ee3ecec-23ce-416d-b45d-63f7232d5f7a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 01:59:01.781174+07	2025-11-04 01:59:03.55786+07	\N	2025-11-03 18:59:00	00:15:00	2025-11-04 01:58:23.781174+07	2025-11-04 01:59:03.578037+07	2025-11-04 02:00:01.781174+07	f	\N	2025-11-04 22:27:01.344506+07
e779e296-35cd-4f22-88a8-30a3853ae67f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 02:00:01.574583+07	2025-11-04 02:00:03.677623+07	\N	2025-11-03 19:00:00	00:15:00	2025-11-04 01:59:03.574583+07	2025-11-04 02:00:03.691263+07	2025-11-04 02:01:01.574583+07	f	\N	2025-11-04 22:27:01.344506+07
eee61b45-8556-4db3-a75a-e9f360a24a6d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 02:01:01.688573+07	2025-11-04 02:01:03.807818+07	\N	2025-11-03 19:01:00	00:15:00	2025-11-04 02:00:03.688573+07	2025-11-04 02:01:03.833494+07	2025-11-04 02:02:01.688573+07	f	\N	2025-11-04 22:27:01.344506+07
aa583a19-f633-4559-8aa5-029a109b6dd3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 02:00:23.332308+07	2025-11-04 02:01:23.275085+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 01:58:23.332308+07	2025-11-04 02:01:23.312383+07	2025-11-04 02:08:23.332308+07	f	\N	2025-11-04 22:27:01.344506+07
03b68fb5-7dba-4d18-b17c-fbad05c1f196	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 02:02:01.828591+07	2025-11-04 02:02:03.929573+07	\N	2025-11-03 19:02:00	00:15:00	2025-11-04 02:01:03.828591+07	2025-11-04 02:02:04.061651+07	2025-11-04 02:03:01.828591+07	f	\N	2025-11-04 22:27:01.344506+07
58523da3-c310-449f-b074-162b09d23665	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 02:03:01.053456+07	2025-11-04 02:03:04.054443+07	\N	2025-11-03 19:03:00	00:15:00	2025-11-04 02:02:04.053456+07	2025-11-04 02:03:04.068768+07	2025-11-04 02:04:01.053456+07	f	\N	2025-11-04 22:27:01.344506+07
85dfd152-aab8-4193-a6f3-3f966e5667c3	__pgboss__cron	0	\N	created	2	0	0	f	2025-11-05 02:29:01.007894+07	\N	\N	2025-11-04 19:29:00	00:15:00	2025-11-05 02:28:00.007894+07	\N	2025-11-05 02:30:01.007894+07	f	\N	2025-11-05 02:31:09.916012+07
e592fb13-9991-4cf0-94c1-69f6e28ec2ff	__pgboss__cron	0	\N	created	2	0	0	f	2025-11-05 02:44:01.946258+07	\N	\N	2025-11-04 19:44:00	00:15:00	2025-11-05 02:43:01.946258+07	\N	2025-11-05 02:45:01.946258+07	f	\N	2025-11-05 02:57:17.015771+07
17fcd296-5ee6-4a76-b737-ea72d82f0260	__pgboss__cron	0	\N	created	2	0	0	f	2025-11-05 03:00:01.737236+07	\N	\N	2025-11-04 20:00:00	00:15:00	2025-11-05 02:59:04.737236+07	\N	2025-11-05 03:01:01.737236+07	f	\N	2025-11-05 03:01:48.377016+07
adb71c35-8fce-4a06-8908-30033e41ff9c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 22:48:01.506488+07	2025-11-04 22:49:01.505139+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 22:46:01.506488+07	2025-11-04 22:49:01.532588+07	2025-11-04 22:56:01.506488+07	f	\N	2025-11-07 21:37:20.719638+07
a225edd8-f23d-4819-8510-f8c9a4a53678	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:28:01.490544+07	2025-11-04 22:28:01.613008+07	\N	2025-11-04 15:28:00	00:15:00	2025-11-04 22:27:05.490544+07	2025-11-04 22:28:01.687229+07	2025-11-04 22:29:01.490544+07	f	\N	2025-11-07 21:37:20.719638+07
f086eb2e-e002-4410-b314-ab3bd706a05c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:13:01.180062+07	2025-11-05 01:13:03.258873+07	\N	2025-11-04 18:13:00	00:15:00	2025-11-05 01:12:03.180062+07	2025-11-05 01:13:03.272164+07	2025-11-05 01:14:01.180062+07	f	\N	2025-11-07 21:37:20.719638+07
6aceaa6b-c65d-4ba9-a1ca-fdd7b7334c9e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:38:01.256157+07	2025-11-04 23:38:02.346829+07	\N	2025-11-04 16:38:00	00:15:00	2025-11-04 23:37:02.256157+07	2025-11-04 23:38:02.360704+07	2025-11-04 23:39:01.256157+07	f	\N	2025-11-07 21:37:20.719638+07
79811d4e-f4b9-4d77-90fd-5d9e17407542	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:29:01.681068+07	2025-11-04 22:29:01.750461+07	\N	2025-11-04 15:29:00	00:15:00	2025-11-04 22:28:01.681068+07	2025-11-04 22:29:01.765809+07	2025-11-04 22:30:01.681068+07	f	\N	2025-11-07 21:37:20.719638+07
8e73657f-36e8-4cf9-954d-6063b5447fa1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 22:29:01.372169+07	2025-11-04 22:30:01.3453+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 22:27:01.372169+07	2025-11-04 22:30:01.396354+07	2025-11-04 22:37:01.372169+07	f	\N	2025-11-07 21:37:20.719638+07
fc7a8f28-117b-423e-857c-6b5c592868c1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:49:01.272502+07	2025-11-04 22:49:04.356347+07	\N	2025-11-04 15:49:00	00:15:00	2025-11-04 22:48:04.272502+07	2025-11-04 22:49:04.378537+07	2025-11-04 22:50:01.272502+07	f	\N	2025-11-07 21:37:20.719638+07
5f7ff926-bbe3-4dee-95cd-b0922748403b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:30:01.693159+07	2025-11-04 22:30:01.899508+07	\N	2025-11-04 15:30:00	00:15:00	2025-11-04 22:29:01.693159+07	2025-11-04 22:30:01.911751+07	2025-11-04 22:31:01.693159+07	f	\N	2025-11-07 21:37:20.719638+07
907c4639-48fa-4c19-a737-e5c5800dc5c4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:50:01.374356+07	2025-11-04 22:50:04.458489+07	\N	2025-11-04 15:50:00	00:15:00	2025-11-04 22:49:04.374356+07	2025-11-04 22:50:04.468997+07	2025-11-04 22:51:01.374356+07	f	\N	2025-11-07 21:37:20.719638+07
19864ccd-020e-4621-8dd8-ec7c172f1f1c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:31:01.909459+07	2025-11-04 22:31:02.021085+07	\N	2025-11-04 15:31:00	00:15:00	2025-11-04 22:30:01.909459+07	2025-11-04 22:31:02.039357+07	2025-11-04 22:32:01.909459+07	f	\N	2025-11-07 21:37:20.719638+07
3fcf6768-860d-434c-9325-e935c3b4a7e3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:51:01.4663+07	2025-11-04 22:51:04.670021+07	\N	2025-11-04 15:51:00	00:15:00	2025-11-04 22:50:04.4663+07	2025-11-04 22:51:04.682281+07	2025-11-04 22:52:01.4663+07	f	\N	2025-11-07 21:37:20.719638+07
c645415f-7ef4-4de4-8207-c4f910e4cb29	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:32:01.034944+07	2025-11-04 22:32:02.160687+07	\N	2025-11-04 15:32:00	00:15:00	2025-11-04 22:31:02.034944+07	2025-11-04 22:32:02.193954+07	2025-11-04 22:33:01.034944+07	f	\N	2025-11-07 21:37:20.719638+07
58be968b-f9b8-4303-b8fb-389cd8411fbd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 22:32:01.406535+07	2025-11-04 22:33:01.377123+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 22:30:01.406535+07	2025-11-04 22:33:01.401814+07	2025-11-04 22:40:01.406535+07	f	\N	2025-11-07 21:37:20.719638+07
b12424a5-1f07-4461-a8e3-e21dfec4618a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 22:51:01.535169+07	2025-11-04 22:52:01.545227+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 22:49:01.535169+07	2025-11-04 22:52:01.57654+07	2025-11-04 22:59:01.535169+07	f	\N	2025-11-07 21:37:20.719638+07
681e92ca-30d5-4b11-bd31-4be3247febfe	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:33:01.189075+07	2025-11-04 22:33:02.239659+07	\N	2025-11-04 15:33:00	00:15:00	2025-11-04 22:32:02.189075+07	2025-11-04 22:33:02.253719+07	2025-11-04 22:34:01.189075+07	f	\N	2025-11-07 21:37:20.719638+07
9cd1a5a1-9402-4a43-aa1d-91ccf12f4103	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:52:01.679937+07	2025-11-04 22:52:04.772681+07	\N	2025-11-04 15:52:00	00:15:00	2025-11-04 22:51:04.679937+07	2025-11-04 22:52:04.787852+07	2025-11-04 22:53:01.679937+07	f	\N	2025-11-07 21:37:20.719638+07
f2e386b8-1cba-431e-95fc-89b04fba009e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:34:01.250178+07	2025-11-04 22:34:02.367524+07	\N	2025-11-04 15:34:00	00:15:00	2025-11-04 22:33:02.250178+07	2025-11-04 22:34:02.402061+07	2025-11-04 22:35:01.250178+07	f	\N	2025-11-07 21:37:20.719638+07
221b4758-796b-423a-9d85-c0260163bbdb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 22:35:01.406588+07	2025-11-04 22:35:01.676818+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 22:33:01.406588+07	2025-11-04 22:35:01.736712+07	2025-11-04 22:43:01.406588+07	f	\N	2025-11-07 21:37:20.719638+07
987bb4df-8701-4257-83d9-06ca524412ac	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:53:01.785503+07	2025-11-04 22:53:04.876925+07	\N	2025-11-04 15:53:00	00:15:00	2025-11-04 22:52:04.785503+07	2025-11-04 22:53:04.887707+07	2025-11-04 22:54:01.785503+07	f	\N	2025-11-07 21:37:20.719638+07
ad29feda-8533-45e6-91d1-5758db7682ad	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:35:01.398446+07	2025-11-04 22:35:02.497182+07	\N	2025-11-04 15:35:00	00:15:00	2025-11-04 22:34:02.398446+07	2025-11-04 22:35:02.529595+07	2025-11-04 22:36:01.398446+07	f	\N	2025-11-07 21:37:20.719638+07
1502a4f2-c9cf-4bb2-a16e-d29e1011cf4d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:54:01.8851+07	2025-11-04 22:54:04.979848+07	\N	2025-11-04 15:54:00	00:15:00	2025-11-04 22:53:04.8851+07	2025-11-04 22:54:04.991761+07	2025-11-04 22:55:01.8851+07	f	\N	2025-11-07 21:37:20.719638+07
947ae5b7-638b-4c20-a197-6c461b05d969	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:36:01.525469+07	2025-11-04 22:36:02.632688+07	\N	2025-11-04 15:36:00	00:15:00	2025-11-04 22:35:02.525469+07	2025-11-04 22:36:02.646553+07	2025-11-04 22:37:01.525469+07	f	\N	2025-11-07 21:37:20.719638+07
cd10e748-11b4-4f1a-b6b5-e065e2032366	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 22:54:01.57993+07	2025-11-04 22:55:01.574659+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 22:52:01.57993+07	2025-11-04 22:55:01.58942+07	2025-11-04 23:02:01.57993+07	f	\N	2025-11-07 21:37:20.719638+07
a02c2fd3-69a7-4892-a279-f3226b62f26a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:37:01.644111+07	2025-11-04 22:37:02.759542+07	\N	2025-11-04 15:37:00	00:15:00	2025-11-04 22:36:02.644111+07	2025-11-04 22:37:02.77134+07	2025-11-04 22:38:01.644111+07	f	\N	2025-11-07 21:37:20.719638+07
c367ec2e-4b3c-4a89-9c50-d721baf13f96	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 22:37:01.742528+07	2025-11-04 22:38:01.42497+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 22:35:01.742528+07	2025-11-04 22:38:01.434644+07	2025-11-04 22:45:01.742528+07	f	\N	2025-11-07 21:37:20.719638+07
de804dfb-5879-4bd4-907e-c24cfc7067af	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:55:01.989503+07	2025-11-04 22:55:05.063904+07	\N	2025-11-04 15:55:00	00:15:00	2025-11-04 22:54:04.989503+07	2025-11-04 22:55:05.072912+07	2025-11-04 22:56:01.989503+07	f	\N	2025-11-07 21:37:20.719638+07
dfd47a0d-7d5d-433d-8c73-862a1d70a1e9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:38:01.768621+07	2025-11-04 22:38:02.858748+07	\N	2025-11-04 15:38:00	00:15:00	2025-11-04 22:37:02.768621+07	2025-11-04 22:38:02.865878+07	2025-11-04 22:39:01.768621+07	f	\N	2025-11-07 21:37:20.719638+07
87fbe166-7490-4528-92a4-11b79076e7a8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:39:01.86436+07	2025-11-04 22:39:03.009983+07	\N	2025-11-04 15:39:00	00:15:00	2025-11-04 22:38:02.86436+07	2025-11-04 22:39:03.024596+07	2025-11-04 22:40:01.86436+07	f	\N	2025-11-07 21:37:20.719638+07
f34ece58-13bb-45e2-b8bd-2ec5ebd86f99	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:56:01.070279+07	2025-11-04 22:56:01.155075+07	\N	2025-11-04 15:56:00	00:15:00	2025-11-04 22:55:05.070279+07	2025-11-04 22:56:01.173126+07	2025-11-04 22:57:01.070279+07	f	\N	2025-11-07 21:37:20.719638+07
d79bf58b-42ab-44bf-bc73-1940b1f060f0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 22:40:01.438503+07	2025-11-04 22:40:01.438806+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 22:38:01.438503+07	2025-11-04 22:40:01.451164+07	2025-11-04 22:48:01.438503+07	f	\N	2025-11-07 21:37:20.719638+07
6490b6da-ecfe-4d84-8a99-b7339b43bf7d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:57:01.167722+07	2025-11-04 22:57:01.254152+07	\N	2025-11-04 15:57:00	00:15:00	2025-11-04 22:56:01.167722+07	2025-11-04 22:57:01.263689+07	2025-11-04 22:58:01.167722+07	f	\N	2025-11-07 21:37:20.719638+07
dd70c14d-ac52-49a5-8b5c-4e5b2197f185	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:40:01.021261+07	2025-11-04 22:40:03.136523+07	\N	2025-11-04 15:40:00	00:15:00	2025-11-04 22:39:03.021261+07	2025-11-04 22:40:03.145749+07	2025-11-04 22:41:01.021261+07	f	\N	2025-11-07 21:37:20.719638+07
61baf8c7-6518-475c-b3fc-433a830be60d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:41:01.143545+07	2025-11-04 22:41:03.362294+07	\N	2025-11-04 15:41:00	00:15:00	2025-11-04 22:40:03.143545+07	2025-11-04 22:41:03.389965+07	2025-11-04 22:42:01.143545+07	f	\N	2025-11-07 21:37:20.719638+07
0b31aaeb-1b29-47a6-930d-bf9afa1c29f9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 22:27:01.297333+07	2025-11-04 22:27:01.320271+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 22:27:01.297333+07	2025-11-04 22:27:01.364894+07	2025-11-04 22:35:01.297333+07	f	\N	2025-11-07 21:37:20.719638+07
a27bbb01-bf14-4b6b-a8ed-a5cfe1ce094b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:58:01.261244+07	2025-11-04 22:58:01.361239+07	\N	2025-11-04 15:58:00	00:15:00	2025-11-04 22:57:01.261244+07	2025-11-04 22:58:01.37164+07	2025-11-04 22:59:01.261244+07	f	\N	2025-11-07 21:37:20.719638+07
35461613-46a5-4944-96bd-3dfe7fd21927	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 22:57:01.594182+07	2025-11-04 22:58:01.594575+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 22:55:01.594182+07	2025-11-04 22:58:01.60514+07	2025-11-04 23:05:01.594182+07	f	\N	2025-11-07 21:37:20.719638+07
e56d2e21-1147-4eb0-bff8-8d7228902e89	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:42:01.383232+07	2025-11-04 22:42:03.4489+07	\N	2025-11-04 15:42:00	00:15:00	2025-11-04 22:41:03.383232+07	2025-11-04 22:42:03.459+07	2025-11-04 22:43:01.383232+07	f	\N	2025-11-07 21:37:20.719638+07
41fc89ab-2881-44ed-9461-76d989ba0f05	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 22:42:01.455191+07	2025-11-04 22:43:01.460084+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 22:40:01.455191+07	2025-11-04 22:43:01.481008+07	2025-11-04 22:50:01.455191+07	f	\N	2025-11-07 21:37:20.719638+07
967b9b09-a545-4e12-b19b-17ff1ed89ff3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:27:01.639845+07	2025-11-04 22:27:05.477007+07	\N	2025-11-04 15:27:00	00:15:00	2025-11-04 22:27:01.639845+07	2025-11-04 22:27:05.493406+07	2025-11-04 22:28:01.639845+07	f	\N	2025-11-07 21:37:20.719638+07
22ab5297-cbba-484e-bd8f-83b6d31804e8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:43:01.456705+07	2025-11-04 22:43:03.589212+07	\N	2025-11-04 15:43:00	00:15:00	2025-11-04 22:42:03.456705+07	2025-11-04 22:43:03.598043+07	2025-11-04 22:44:01.456705+07	f	\N	2025-11-07 21:37:20.719638+07
9c4525e1-b5c0-465e-87d6-d500ef1e016f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:01:01.603578+07	2025-11-04 23:01:01.690175+07	\N	2025-11-04 16:01:00	00:15:00	2025-11-04 23:00:01.603578+07	2025-11-04 23:01:01.700956+07	2025-11-04 23:02:01.603578+07	f	\N	2025-11-07 21:37:20.719638+07
c8cba1a9-70ba-4ce5-bd92-04a89a33c426	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:44:01.595392+07	2025-11-04 22:44:03.720843+07	\N	2025-11-04 15:44:00	00:15:00	2025-11-04 22:43:03.595392+07	2025-11-04 22:44:03.740923+07	2025-11-04 22:45:01.595392+07	f	\N	2025-11-07 21:37:20.719638+07
3c5c5701-ac88-40ef-9571-b786e8a0cf8e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:45:01.734876+07	2025-11-04 22:45:03.863801+07	\N	2025-11-04 15:45:00	00:15:00	2025-11-04 22:44:03.734876+07	2025-11-04 22:45:03.880942+07	2025-11-04 22:46:01.734876+07	f	\N	2025-11-07 21:37:20.719638+07
0ce6d790-36f3-43ae-9296-c69b9be0e7e0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 22:45:01.48533+07	2025-11-04 22:46:01.484766+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 22:43:01.48533+07	2025-11-04 22:46:01.503286+07	2025-11-04 22:53:01.48533+07	f	\N	2025-11-07 21:37:20.719638+07
688b69e0-11e0-445b-a642-a8c3829ea3c7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:46:01.877148+07	2025-11-04 22:46:03.997748+07	\N	2025-11-04 15:46:00	00:15:00	2025-11-04 22:45:03.877148+07	2025-11-04 22:46:04.007018+07	2025-11-04 22:47:01.877148+07	f	\N	2025-11-07 21:37:20.719638+07
aa2e6cc7-5b72-482d-9ef3-e6bcf3097423	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:47:01.004787+07	2025-11-04 22:47:04.130058+07	\N	2025-11-04 15:47:00	00:15:00	2025-11-04 22:46:04.004787+07	2025-11-04 22:47:04.144021+07	2025-11-04 22:48:01.004787+07	f	\N	2025-11-07 21:37:20.719638+07
4d667f3e-6483-4216-b3e6-6ace3e44c5b5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:48:01.141189+07	2025-11-04 22:48:04.246536+07	\N	2025-11-04 15:48:00	00:15:00	2025-11-04 22:47:04.141189+07	2025-11-04 22:48:04.277586+07	2025-11-04 22:49:01.141189+07	f	\N	2025-11-07 21:37:20.719638+07
d5ad7f9d-e5c7-4f1e-9271-b43446103802	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 22:59:01.368611+07	2025-11-04 22:59:01.46465+07	\N	2025-11-04 15:59:00	00:15:00	2025-11-04 22:58:01.368611+07	2025-11-04 22:59:01.475661+07	2025-11-04 23:00:01.368611+07	f	\N	2025-11-07 21:37:20.719638+07
d5a22a80-31e9-45b7-94d2-065eb2c5eb13	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:37:01.147131+07	2025-11-04 23:37:02.249013+07	\N	2025-11-04 16:37:00	00:15:00	2025-11-04 23:36:02.147131+07	2025-11-04 23:37:02.261078+07	2025-11-04 23:38:01.147131+07	f	\N	2025-11-07 21:37:20.719638+07
1f4b498c-3d25-4955-beeb-9dc32bd187e9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:13:01.061612+07	2025-11-04 23:13:03.198709+07	\N	2025-11-04 16:13:00	00:15:00	2025-11-04 23:12:03.061612+07	2025-11-04 23:13:03.256719+07	2025-11-04 23:14:01.061612+07	f	\N	2025-11-07 21:37:20.719638+07
c67cb681-86ce-4aca-8538-f010596f9070	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:02:01.698701+07	2025-11-04 23:02:01.895792+07	\N	2025-11-04 16:02:00	00:15:00	2025-11-04 23:01:01.698701+07	2025-11-04 23:02:01.941232+07	2025-11-04 23:03:01.698701+07	f	\N	2025-11-07 21:37:20.719638+07
d12b3abc-ff5b-40bc-909c-608346b13109	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:04:02.134741+07	2025-11-05 00:05:02.133084+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:02:02.134741+07	2025-11-05 00:05:02.195466+07	2025-11-05 00:12:02.134741+07	f	\N	2025-11-07 21:37:20.719638+07
f21c5b1e-a592-45ec-b798-3bb0cd7083e5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:03:01.936892+07	2025-11-04 23:03:02.000965+07	\N	2025-11-04 16:03:00	00:15:00	2025-11-04 23:02:01.936892+07	2025-11-04 23:03:02.02518+07	2025-11-04 23:04:01.936892+07	f	\N	2025-11-07 21:37:20.719638+07
90cef2e6-b693-4419-8def-95f0d6e909bc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:38:01.9226+07	2025-11-04 23:38:01.932245+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:36:01.9226+07	2025-11-04 23:38:01.947229+07	2025-11-04 23:46:01.9226+07	f	\N	2025-11-07 21:37:20.719638+07
70a205e2-c9c9-4b7d-a358-058075bc612b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:14:01.253551+07	2025-11-04 23:14:03.340586+07	\N	2025-11-04 16:14:00	00:15:00	2025-11-04 23:13:03.253551+07	2025-11-04 23:14:03.359565+07	2025-11-04 23:15:01.253551+07	f	\N	2025-11-07 21:37:20.719638+07
fb539c6a-c1d8-429b-b2af-e767f21eb58a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:15:01.354821+07	2025-11-04 23:15:03.456136+07	\N	2025-11-04 16:15:00	00:15:00	2025-11-04 23:14:03.354821+07	2025-11-04 23:15:03.505002+07	2025-11-04 23:16:01.354821+07	f	\N	2025-11-07 21:37:20.719638+07
12874429-f635-4be3-921c-d5e13c00e6fa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:06:01.830093+07	2025-11-05 00:06:01.959047+07	\N	2025-11-04 17:06:00	00:15:00	2025-11-05 00:05:01.830093+07	2025-11-05 00:06:01.991776+07	2025-11-05 00:07:01.830093+07	f	\N	2025-11-07 21:37:20.719638+07
14893ea3-3d3e-414e-b9ca-fb3f6fcdfb5c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:17:01.569236+07	2025-11-04 23:17:03.701127+07	\N	2025-11-04 16:17:00	00:15:00	2025-11-04 23:16:03.569236+07	2025-11-04 23:17:03.72256+07	2025-11-04 23:18:01.569236+07	f	\N	2025-11-07 21:37:20.719638+07
986c1b9d-414e-4b6c-a092-b23b46fb60aa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:39:01.357432+07	2025-11-04 23:39:02.429545+07	\N	2025-11-04 16:39:00	00:15:00	2025-11-04 23:38:02.357432+07	2025-11-04 23:39:02.440398+07	2025-11-04 23:40:01.357432+07	f	\N	2025-11-07 21:37:20.719638+07
13dfbaef-a8c9-4ef4-9437-4d5c9b3fc9b2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:18:01.717621+07	2025-11-04 23:18:03.812503+07	\N	2025-11-04 16:18:00	00:15:00	2025-11-04 23:17:03.717621+07	2025-11-04 23:18:03.828732+07	2025-11-04 23:19:01.717621+07	f	\N	2025-11-07 21:37:20.719638+07
40eac8a2-ba88-428e-ac82-6473e12f1ec1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:40:01.437397+07	2025-11-04 23:40:02.533377+07	\N	2025-11-04 16:40:00	00:15:00	2025-11-04 23:39:02.437397+07	2025-11-04 23:40:02.544516+07	2025-11-04 23:41:01.437397+07	f	\N	2025-11-07 21:37:20.719638+07
ffc39178-c918-4b3f-8ec8-fc271a22c297	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:19:01.824892+07	2025-11-04 23:19:03.928274+07	\N	2025-11-04 16:19:00	00:15:00	2025-11-04 23:18:03.824892+07	2025-11-04 23:19:03.957975+07	2025-11-04 23:20:01.824892+07	f	\N	2025-11-07 21:37:20.719638+07
dd88ce22-8ec8-4e07-a554-b93761545741	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:07:02.198438+07	2025-11-05 00:08:02.153915+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:05:02.198438+07	2025-11-05 00:08:02.183505+07	2025-11-05 00:15:02.198438+07	f	\N	2025-11-07 21:37:20.719638+07
d3654c8b-db29-426f-8712-debb106c32e6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:40:01.950315+07	2025-11-04 23:41:01.949485+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:38:01.950315+07	2025-11-04 23:41:01.983453+07	2025-11-04 23:48:01.950315+07	f	\N	2025-11-07 21:37:20.719638+07
e7c098b2-8d0d-444b-9ff9-60f6e4b15780	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:20:01.815216+07	2025-11-04 23:21:01.775875+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:18:01.815216+07	2025-11-04 23:21:01.827073+07	2025-11-04 23:28:01.815216+07	f	\N	2025-11-07 21:37:20.719638+07
8d2b7ef4-9886-40c5-bf69-92ceb2059ea9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:21:01.058394+07	2025-11-04 23:21:04.375172+07	\N	2025-11-04 16:21:00	00:15:00	2025-11-04 23:20:06.058394+07	2025-11-04 23:21:04.387092+07	2025-11-04 23:22:01.058394+07	f	\N	2025-11-07 21:37:20.719638+07
2598f8e9-efd7-4b64-8674-d7d3d76ff2bc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:41:01.541457+07	2025-11-04 23:41:02.645812+07	\N	2025-11-04 16:41:00	00:15:00	2025-11-04 23:40:02.541457+07	2025-11-04 23:41:02.659488+07	2025-11-04 23:42:01.541457+07	f	\N	2025-11-07 21:37:20.719638+07
e2bc3185-61d0-4add-b307-bfc4eae463c6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:10:02.189074+07	2025-11-05 00:11:02.185728+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:08:02.189074+07	2025-11-05 00:11:02.236446+07	2025-11-05 00:18:02.189074+07	f	\N	2025-11-07 21:37:20.719638+07
5a9c49eb-64eb-4866-80bd-215034b7c15a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:24:01.621869+07	2025-11-04 23:24:04.725257+07	\N	2025-11-04 16:24:00	00:15:00	2025-11-04 23:23:04.621869+07	2025-11-04 23:24:04.735187+07	2025-11-04 23:25:01.621869+07	f	\N	2025-11-07 21:37:20.719638+07
6de9c4fa-5965-46ad-9b3b-291348e01ad4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:43:01.815572+07	2025-11-04 23:43:02.909123+07	\N	2025-11-04 16:43:00	00:15:00	2025-11-04 23:42:02.815572+07	2025-11-04 23:43:02.91655+07	2025-11-04 23:44:01.815572+07	f	\N	2025-11-07 21:37:20.719638+07
14f5e9ea-0402-47fc-86e4-6314df7cf92d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:25:01.733052+07	2025-11-04 23:25:04.856632+07	\N	2025-11-04 16:25:00	00:15:00	2025-11-04 23:24:04.733052+07	2025-11-04 23:25:04.869662+07	2025-11-04 23:26:01.733052+07	f	\N	2025-11-07 21:37:20.719638+07
063936ef-9664-4f62-b43b-96a8ca98cb05	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:26:01.867124+07	2025-11-04 23:26:04.974769+07	\N	2025-11-04 16:26:00	00:15:00	2025-11-04 23:25:04.867124+07	2025-11-04 23:26:04.982995+07	2025-11-04 23:27:01.867124+07	f	\N	2025-11-07 21:37:20.719638+07
6e3fc20e-9ba8-4b94-8b4d-fc445afc5844	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:44:01.914707+07	2025-11-04 23:44:03.013197+07	\N	2025-11-04 16:44:00	00:15:00	2025-11-04 23:43:02.914707+07	2025-11-04 23:44:03.023323+07	2025-11-04 23:45:01.914707+07	f	\N	2025-11-07 21:37:20.719638+07
3b25ee01-3185-459c-b9ac-8843ed238955	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:30:01.311998+07	2025-11-04 23:30:01.415142+07	\N	2025-11-04 16:30:00	00:15:00	2025-11-04 23:29:01.311998+07	2025-11-04 23:30:01.424736+07	2025-11-04 23:31:01.311998+07	f	\N	2025-11-07 21:37:20.719638+07
456caad2-5d19-465e-96b5-cfed7c2b7569	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:49:01.450531+07	2025-11-04 23:49:03.991991+07	\N	2025-11-04 16:49:00	00:15:00	2025-11-04 23:48:03.450531+07	2025-11-04 23:49:04.09537+07	2025-11-04 23:50:01.450531+07	f	\N	2025-11-07 21:37:20.719638+07
a8589cc3-02e8-4ed5-9f52-879eabe5afba	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:31:01.421977+07	2025-11-04 23:31:01.549544+07	\N	2025-11-04 16:31:00	00:15:00	2025-11-04 23:30:01.421977+07	2025-11-04 23:31:01.561905+07	2025-11-04 23:32:01.421977+07	f	\N	2025-11-07 21:37:20.719638+07
21d3527d-3c1e-4f66-bd6a-67667723913a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:52:01.2283+07	2025-11-04 23:52:04.347357+07	\N	2025-11-04 16:52:00	00:15:00	2025-11-04 23:51:04.2283+07	2025-11-04 23:52:04.361459+07	2025-11-04 23:53:01.2283+07	f	\N	2025-11-07 21:37:20.719638+07
79c54f29-d353-4d54-bfdb-6ae2ef8403b2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:32:01.558005+07	2025-11-04 23:32:01.650957+07	\N	2025-11-04 16:32:00	00:15:00	2025-11-04 23:31:01.558005+07	2025-11-04 23:32:01.669868+07	2025-11-04 23:33:01.558005+07	f	\N	2025-11-07 21:37:20.719638+07
c12d74c8-d3c7-43da-b330-96db3c45b4c3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:52:02.019873+07	2025-11-04 23:53:02.005873+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:50:02.019873+07	2025-11-04 23:53:02.030895+07	2025-11-05 00:00:02.019873+07	f	\N	2025-11-07 21:37:20.719638+07
7bd17ce8-5ad8-4ae5-9e19-05e2a8e97dfd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:33:01.666501+07	2025-11-04 23:33:01.783552+07	\N	2025-11-04 16:33:00	00:15:00	2025-11-04 23:32:01.666501+07	2025-11-04 23:33:01.798561+07	2025-11-04 23:34:01.666501+07	f	\N	2025-11-07 21:37:20.719638+07
9615c951-764f-4c3f-a9da-210967863cec	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:32:01.891211+07	2025-11-04 23:33:01.892546+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:30:01.891211+07	2025-11-04 23:33:01.921463+07	2025-11-04 23:40:01.891211+07	f	\N	2025-11-07 21:37:20.719638+07
888006ca-d2a8-4eb4-820b-bee7aad5f835	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:55:02.033883+07	2025-11-04 23:56:02.042429+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:53:02.033883+07	2025-11-04 23:56:02.074372+07	2025-11-05 00:03:02.033883+07	f	\N	2025-11-07 21:37:20.719638+07
f6f34d86-c47e-4bd0-9c22-1ab41d666537	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:34:01.795591+07	2025-11-04 23:34:01.905196+07	\N	2025-11-04 16:34:00	00:15:00	2025-11-04 23:33:01.795591+07	2025-11-04 23:34:01.915117+07	2025-11-04 23:35:01.795591+07	f	\N	2025-11-07 21:37:20.719638+07
df6011d5-6b9d-41f9-b13a-b53860c4f08f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:35:01.912785+07	2025-11-04 23:35:02.016107+07	\N	2025-11-04 16:35:00	00:15:00	2025-11-04 23:34:01.912785+07	2025-11-04 23:35:02.031802+07	2025-11-04 23:36:01.912785+07	f	\N	2025-11-07 21:37:20.719638+07
88d5263a-ff24-4478-a935-1b74753be729	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:56:01.704068+07	2025-11-04 23:56:04.801134+07	\N	2025-11-04 16:56:00	00:15:00	2025-11-04 23:55:04.704068+07	2025-11-04 23:56:04.813571+07	2025-11-04 23:57:01.704068+07	f	\N	2025-11-07 21:37:20.719638+07
4e0e3b3a-472a-41aa-b8d8-9c8db337cb88	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:35:01.927213+07	2025-11-04 23:36:01.910797+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:33:01.927213+07	2025-11-04 23:36:01.920114+07	2025-11-04 23:43:01.927213+07	f	\N	2025-11-07 21:37:20.719638+07
36ab35c3-c449-443a-b9f8-fe0c7f91c7c9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:36:01.029366+07	2025-11-04 23:36:02.140446+07	\N	2025-11-04 16:36:00	00:15:00	2025-11-04 23:35:02.029366+07	2025-11-04 23:36:02.149288+07	2025-11-04 23:37:01.029366+07	f	\N	2025-11-07 21:37:20.719638+07
0bc1c24f-fe42-4945-99d0-dbb61707f095	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:57:01.810331+07	2025-11-04 23:57:04.884327+07	\N	2025-11-04 16:57:00	00:15:00	2025-11-04 23:56:04.810331+07	2025-11-04 23:57:04.895354+07	2025-11-04 23:58:01.810331+07	f	\N	2025-11-07 21:37:20.719638+07
344302cb-e661-42a6-96c8-6eb1ab409998	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:58:01.892856+07	2025-11-04 23:58:05.010371+07	\N	2025-11-04 16:58:00	00:15:00	2025-11-04 23:57:04.892856+07	2025-11-04 23:58:05.037682+07	2025-11-04 23:59:01.892856+07	f	\N	2025-11-07 21:37:20.719638+07
fa986cff-3afe-4e1f-8c6e-8fc5749fc30e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:01:01.267793+07	2025-11-05 00:01:01.344116+07	\N	2025-11-04 17:01:00	00:15:00	2025-11-05 00:00:01.267793+07	2025-11-05 00:01:01.356543+07	2025-11-05 00:02:01.267793+07	f	\N	2025-11-07 21:37:20.719638+07
9b399b3e-115d-4907-b4e6-d09289750f4f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:02:01.351451+07	2025-11-05 00:02:01.464905+07	\N	2025-11-04 17:02:00	00:15:00	2025-11-05 00:01:01.351451+07	2025-11-05 00:02:01.509376+07	2025-11-05 00:03:01.351451+07	f	\N	2025-11-07 21:37:20.719638+07
dcf5991f-64da-407d-b4d6-ad3a1552ad5a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:03:01.50319+07	2025-11-05 00:03:01.57112+07	\N	2025-11-04 17:03:00	00:15:00	2025-11-05 00:02:01.50319+07	2025-11-05 00:03:01.641037+07	2025-11-05 00:04:01.50319+07	f	\N	2025-11-07 21:37:20.719638+07
7ac869a7-2127-450d-afef-756b565c4040	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:04:01.632695+07	2025-11-05 00:04:01.690261+07	\N	2025-11-04 17:04:00	00:15:00	2025-11-05 00:03:01.632695+07	2025-11-05 00:04:01.706091+07	2025-11-05 00:05:01.632695+07	f	\N	2025-11-07 21:37:20.719638+07
e9e73c92-af2b-46c8-b733-186f365fdb46	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:00:01.472873+07	2025-11-04 23:00:01.582938+07	\N	2025-11-04 16:00:00	00:15:00	2025-11-04 22:59:01.472873+07	2025-11-04 23:00:01.608375+07	2025-11-04 23:01:01.472873+07	f	\N	2025-11-07 21:37:20.719638+07
643b5877-8b2c-46c9-82b5-e93231dad7f2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:00:01.60805+07	2025-11-04 23:01:01.612907+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 22:58:01.60805+07	2025-11-04 23:01:01.627658+07	2025-11-04 23:08:01.60805+07	f	\N	2025-11-07 21:37:20.719638+07
325cc716-f9de-4bb7-9b74-7ed6e1231df5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:12:01.890025+07	2025-11-04 23:12:03.05408+07	\N	2025-11-04 16:12:00	00:15:00	2025-11-04 23:11:02.890025+07	2025-11-04 23:12:03.066055+07	2025-11-04 23:13:01.890025+07	f	\N	2025-11-07 21:37:20.719638+07
a3d072c0-9a9e-4993-b619-d6aa430ee54f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:05:01.702944+07	2025-11-05 00:05:01.805826+07	\N	2025-11-04 17:05:00	00:15:00	2025-11-05 00:04:01.702944+07	2025-11-05 00:05:01.850116+07	2025-11-05 00:06:01.702944+07	f	\N	2025-11-07 21:37:20.719638+07
9aba222d-b7cd-464b-9f3b-731fb0267427	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:12:01.724926+07	2025-11-04 23:13:01.699757+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:10:01.724926+07	2025-11-04 23:13:01.718858+07	2025-11-04 23:20:01.724926+07	f	\N	2025-11-07 21:37:20.719638+07
c2626412-146c-4b1a-887f-a9c3bef58c5b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:03:01.630458+07	2025-11-04 23:04:01.623038+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:01:01.630458+07	2025-11-04 23:04:01.647007+07	2025-11-04 23:11:01.630458+07	f	\N	2025-11-07 21:37:20.719638+07
f8865328-6d05-4e2b-8397-a7ac17e8d1cc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:15:01.722388+07	2025-11-04 23:15:01.726294+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:13:01.722388+07	2025-11-04 23:15:01.746372+07	2025-11-04 23:23:01.722388+07	f	\N	2025-11-07 21:37:20.719638+07
f91b9d2b-6d4f-4418-86ea-5fcb433a0220	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:42:01.656873+07	2025-11-04 23:42:02.803629+07	\N	2025-11-04 16:42:00	00:15:00	2025-11-04 23:41:02.656873+07	2025-11-04 23:42:02.818227+07	2025-11-04 23:43:01.656873+07	f	\N	2025-11-07 21:37:20.719638+07
f76afd91-3b5b-4e98-86a4-eab89fcd6433	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:04:01.021268+07	2025-11-04 23:04:02.128484+07	\N	2025-11-04 16:04:00	00:15:00	2025-11-04 23:03:02.021268+07	2025-11-04 23:04:02.137196+07	2025-11-04 23:05:01.021268+07	f	\N	2025-11-07 21:37:20.719638+07
5839702f-ae6f-4be7-bb9b-e0bee50fb1a4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:43:01.987714+07	2025-11-04 23:44:01.962886+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:41:01.987714+07	2025-11-04 23:44:01.987142+07	2025-11-04 23:51:01.987714+07	f	\N	2025-11-07 21:37:20.719638+07
f7e0a254-97fd-4552-833b-b235a0040d7c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:05:01.02602+07	2025-11-04 23:05:02.253707+07	\N	2025-11-04 16:05:00	00:15:00	2025-11-04 23:04:02.02602+07	2025-11-04 23:05:02.271906+07	2025-11-04 23:06:01.02602+07	f	\N	2025-11-07 21:37:20.719638+07
706b36ad-d470-42eb-a43f-0ce6bde90730	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:16:01.499397+07	2025-11-04 23:16:03.559949+07	\N	2025-11-04 16:16:00	00:15:00	2025-11-04 23:15:03.499397+07	2025-11-04 23:16:03.571502+07	2025-11-04 23:17:01.499397+07	f	\N	2025-11-07 21:37:20.719638+07
868d7445-35bd-4f30-b350-605de2e57289	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:06:01.267554+07	2025-11-04 23:06:02.358634+07	\N	2025-11-04 16:06:00	00:15:00	2025-11-04 23:05:02.267554+07	2025-11-04 23:06:02.36875+07	2025-11-04 23:07:01.267554+07	f	\N	2025-11-07 21:37:20.719638+07
66b4a984-44ea-4575-a170-c312a312e972	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:17:01.750841+07	2025-11-04 23:18:01.752031+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:15:01.750841+07	2025-11-04 23:18:01.803628+07	2025-11-04 23:25:01.750841+07	f	\N	2025-11-07 21:37:20.719638+07
52afad10-7bf6-41f7-bb59-f5fceea5d407	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:06:01.650467+07	2025-11-04 23:07:01.654355+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:04:01.650467+07	2025-11-04 23:07:01.675124+07	2025-11-04 23:14:01.650467+07	f	\N	2025-11-07 21:37:20.719638+07
43c2b5ce-c2dc-4de1-a765-34abdef53edc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:20:01.952628+07	2025-11-04 23:20:05.183154+07	\N	2025-11-04 16:20:00	00:15:00	2025-11-04 23:19:03.952628+07	2025-11-04 23:20:06.078633+07	2025-11-04 23:21:01.952628+07	f	\N	2025-11-07 21:37:20.719638+07
7fe228a6-949f-4e9a-a53f-dd2a6ab8ef96	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:07:01.366567+07	2025-11-04 23:07:02.440193+07	\N	2025-11-04 16:07:00	00:15:00	2025-11-04 23:06:02.366567+07	2025-11-04 23:07:02.455296+07	2025-11-04 23:08:01.366567+07	f	\N	2025-11-07 21:37:20.719638+07
493519d5-01be-4e1c-867b-d4ccd92fc233	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:45:01.020903+07	2025-11-04 23:45:03.108974+07	\N	2025-11-04 16:45:00	00:15:00	2025-11-04 23:44:03.020903+07	2025-11-04 23:45:03.119637+07	2025-11-04 23:46:01.020903+07	f	\N	2025-11-07 21:37:20.719638+07
86a6898b-7cca-4ad3-9e0d-58eb1d32fb11	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:08:01.451689+07	2025-11-04 23:08:02.540204+07	\N	2025-11-04 16:08:00	00:15:00	2025-11-04 23:07:02.451689+07	2025-11-04 23:08:02.565302+07	2025-11-04 23:09:01.451689+07	f	\N	2025-11-07 21:37:20.719638+07
0f484dde-4bf0-4f6f-9bbf-d00a4e180c67	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:09:01.560521+07	2025-11-04 23:09:02.645477+07	\N	2025-11-04 16:09:00	00:15:00	2025-11-04 23:08:02.560521+07	2025-11-04 23:09:02.676834+07	2025-11-04 23:10:01.560521+07	f	\N	2025-11-07 21:37:20.719638+07
7121f0d6-6f1a-4f05-96a4-db360069167a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:22:01.385077+07	2025-11-04 23:22:04.521435+07	\N	2025-11-04 16:22:00	00:15:00	2025-11-04 23:21:04.385077+07	2025-11-04 23:22:04.531285+07	2025-11-04 23:23:01.385077+07	f	\N	2025-11-07 21:37:20.719638+07
0baf0746-196c-4bcd-a821-6afdcdcefbc3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:09:01.678758+07	2025-11-04 23:10:01.679417+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:07:01.678758+07	2025-11-04 23:10:01.719981+07	2025-11-04 23:17:01.678758+07	f	\N	2025-11-07 21:37:20.719638+07
1f9a3d6e-5798-4292-a3f9-8f88fbbe58c1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:46:01.118275+07	2025-11-04 23:46:03.197613+07	\N	2025-11-04 16:46:00	00:15:00	2025-11-04 23:45:03.118275+07	2025-11-04 23:46:03.206526+07	2025-11-04 23:47:01.118275+07	f	\N	2025-11-07 21:37:20.719638+07
0cc12eb9-bf5f-4af2-a232-7fb45884cbd0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:23:01.528682+07	2025-11-04 23:23:04.615237+07	\N	2025-11-04 16:23:00	00:15:00	2025-11-04 23:22:04.528682+07	2025-11-04 23:23:04.626109+07	2025-11-04 23:24:01.528682+07	f	\N	2025-11-07 21:37:20.719638+07
3f6b5138-9914-4fed-80b2-c6ee3c3c129b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:10:01.667032+07	2025-11-04 23:10:02.747133+07	\N	2025-11-04 16:10:00	00:15:00	2025-11-04 23:09:02.667032+07	2025-11-04 23:10:02.757676+07	2025-11-04 23:11:01.667032+07	f	\N	2025-11-07 21:37:20.719638+07
4ded25b5-1f78-4f6b-9ff4-281219338bbd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:46:01.990967+07	2025-11-04 23:47:01.978101+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:44:01.990967+07	2025-11-04 23:47:01.989195+07	2025-11-04 23:54:01.990967+07	f	\N	2025-11-07 21:37:20.719638+07
eb437a4f-1241-4e71-a8a4-b6c421e7ddb3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:11:01.754522+07	2025-11-04 23:11:02.880043+07	\N	2025-11-04 16:11:00	00:15:00	2025-11-04 23:10:02.754522+07	2025-11-04 23:11:02.894082+07	2025-11-04 23:12:01.754522+07	f	\N	2025-11-07 21:37:20.719638+07
3a5ea0e3-24b1-4c29-8830-0d0264195dbf	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:23:01.833636+07	2025-11-04 23:24:01.809592+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:21:01.833636+07	2025-11-04 23:24:01.852461+07	2025-11-04 23:31:01.833636+07	f	\N	2025-11-07 21:37:20.719638+07
0cd4fc9a-b5fd-4c0a-ac42-7a90290bc6ae	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:47:01.204273+07	2025-11-04 23:47:03.320399+07	\N	2025-11-04 16:47:00	00:15:00	2025-11-04 23:46:03.204273+07	2025-11-04 23:47:03.331429+07	2025-11-04 23:48:01.204273+07	f	\N	2025-11-07 21:37:20.719638+07
c9b2daaf-7668-4280-9036-b36ab7e5389b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:26:01.856618+07	2025-11-04 23:27:01.833429+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:24:01.856618+07	2025-11-04 23:27:01.85232+07	2025-11-04 23:34:01.856618+07	f	\N	2025-11-07 21:37:20.719638+07
ba336774-66f1-4db2-9fd6-5d827330633a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:48:01.328437+07	2025-11-04 23:48:03.440868+07	\N	2025-11-04 16:48:00	00:15:00	2025-11-04 23:47:03.328437+07	2025-11-04 23:48:03.453107+07	2025-11-04 23:49:01.328437+07	f	\N	2025-11-07 21:37:20.719638+07
d46535b4-647a-43ba-8621-feade15d05f9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:27:01.981143+07	2025-11-04 23:27:05.073917+07	\N	2025-11-04 16:27:00	00:15:00	2025-11-04 23:26:04.981143+07	2025-11-04 23:27:05.083652+07	2025-11-04 23:28:01.981143+07	f	\N	2025-11-07 21:37:20.719638+07
cccc16b7-7702-4711-a6bf-70945d5af551	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:49:01.99229+07	2025-11-04 23:50:01.993391+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:47:01.99229+07	2025-11-04 23:50:02.016987+07	2025-11-04 23:57:01.99229+07	f	\N	2025-11-07 21:37:20.719638+07
8f8b97ea-f062-4e7e-b8d9-f352fad703d5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:28:01.080949+07	2025-11-04 23:28:01.181883+07	\N	2025-11-04 16:28:00	00:15:00	2025-11-04 23:27:05.080949+07	2025-11-04 23:28:01.190855+07	2025-11-04 23:29:01.080949+07	f	\N	2025-11-07 21:37:20.719638+07
55b01f22-977d-41f8-8bc6-72a2e59bac39	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:29:01.188467+07	2025-11-04 23:29:01.293482+07	\N	2025-11-04 16:29:00	00:15:00	2025-11-04 23:28:01.188467+07	2025-11-04 23:29:01.316607+07	2025-11-04 23:30:01.188467+07	f	\N	2025-11-07 21:37:20.719638+07
814fb2b8-ee6a-4acb-a086-46a6efa4e6ec	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:29:01.855835+07	2025-11-04 23:30:01.867461+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:27:01.855835+07	2025-11-04 23:30:01.888766+07	2025-11-04 23:37:01.855835+07	f	\N	2025-11-07 21:37:20.719638+07
60fe8d63-891e-498e-a8b0-169f8b423344	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:50:01.092191+07	2025-11-04 23:50:04.108643+07	\N	2025-11-04 16:50:00	00:15:00	2025-11-04 23:49:04.092191+07	2025-11-04 23:50:04.118607+07	2025-11-04 23:51:01.092191+07	f	\N	2025-11-07 21:37:20.719638+07
f9154ed8-c169-4eaa-b1cc-f9fd8dc4a376	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:51:01.115993+07	2025-11-04 23:51:04.209112+07	\N	2025-11-04 16:51:00	00:15:00	2025-11-04 23:50:04.115993+07	2025-11-04 23:51:04.233045+07	2025-11-04 23:52:01.115993+07	f	\N	2025-11-07 21:37:20.719638+07
0a05eb4b-ac94-4462-b1e4-02da65f32a0f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:53:01.35862+07	2025-11-04 23:53:04.447501+07	\N	2025-11-04 16:53:00	00:15:00	2025-11-04 23:52:04.35862+07	2025-11-04 23:53:04.4579+07	2025-11-04 23:54:01.35862+07	f	\N	2025-11-07 21:37:20.719638+07
756a20cd-54a7-4d5e-bd51-c769b0776739	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:54:01.454092+07	2025-11-04 23:54:04.552935+07	\N	2025-11-04 16:54:00	00:15:00	2025-11-04 23:53:04.454092+07	2025-11-04 23:54:04.565799+07	2025-11-04 23:55:01.454092+07	f	\N	2025-11-07 21:37:20.719638+07
6221025f-afcb-4030-9487-1d58d0de99e6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:55:01.562547+07	2025-11-04 23:55:04.688735+07	\N	2025-11-04 16:55:00	00:15:00	2025-11-04 23:54:04.562547+07	2025-11-04 23:55:04.708291+07	2025-11-04 23:56:01.562547+07	f	\N	2025-11-07 21:37:20.719638+07
32810477-5aaa-4297-8d06-a6aaf4362b2b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-04 23:59:01.033676+07	2025-11-04 23:59:01.125039+07	\N	2025-11-04 16:59:00	00:15:00	2025-11-04 23:58:05.033676+07	2025-11-04 23:59:01.172942+07	2025-11-05 00:00:01.033676+07	f	\N	2025-11-07 21:37:20.719638+07
3bac5236-02b4-4c5f-8fce-91aee7b25453	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-04 23:58:02.078853+07	2025-11-04 23:59:02.069356+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:56:02.078853+07	2025-11-04 23:59:02.095028+07	2025-11-05 00:06:02.078853+07	f	\N	2025-11-07 21:37:20.719638+07
3ab7531b-40ce-4abe-805a-8c3b22702a9c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:00:01.168038+07	2025-11-05 00:00:01.244093+07	\N	2025-11-04 17:00:00	00:15:00	2025-11-04 23:59:01.168038+07	2025-11-05 00:00:01.271625+07	2025-11-05 00:01:01.168038+07	f	\N	2025-11-07 21:37:20.719638+07
bebddb6a-a5e4-41df-a513-47d66bbe8633	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:01:02.101619+07	2025-11-05 00:02:02.102981+07	__pgboss__maintenance	\N	00:15:00	2025-11-04 23:59:02.101619+07	2025-11-05 00:02:02.131066+07	2025-11-05 00:09:02.101619+07	f	\N	2025-11-07 21:37:20.719638+07
8b0eaca7-ffd0-4b29-8a91-00a70680b0f3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:07:01.988335+07	2025-11-05 00:07:02.090792+07	\N	2025-11-04 17:07:00	00:15:00	2025-11-05 00:06:01.988335+07	2025-11-05 00:07:02.105277+07	2025-11-05 00:08:01.988335+07	f	\N	2025-11-07 21:37:20.719638+07
91fe9a8b-8b5e-4eb7-b319-0ca42bcc10bc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:12:01.047782+07	2025-11-05 01:12:03.150267+07	\N	2025-11-04 18:12:00	00:15:00	2025-11-05 01:11:03.047782+07	2025-11-05 01:12:03.183297+07	2025-11-05 01:13:01.047782+07	f	\N	2025-11-07 21:37:20.719638+07
1ee0aafe-e020-4d9a-b2ad-38e24b9d754b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:36:01.568592+07	2025-11-05 00:36:01.645676+07	\N	2025-11-04 17:36:00	00:15:00	2025-11-05 00:35:01.568592+07	2025-11-05 00:36:01.70316+07	2025-11-05 00:37:01.568592+07	f	\N	2025-11-07 21:37:20.719638+07
75879502-24cd-4f52-8735-0e7a63857446	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:08:01.101455+07	2025-11-05 00:08:02.189379+07	\N	2025-11-04 17:08:00	00:15:00	2025-11-05 00:07:02.101455+07	2025-11-05 00:08:02.244489+07	2025-11-05 00:09:01.101455+07	f	\N	2025-11-07 21:37:20.719638+07
2cdf2819-ad4a-4b3e-9ab4-2861c30e2fe0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:37:01.694976+07	2025-11-05 00:37:01.754766+07	\N	2025-11-04 17:37:00	00:15:00	2025-11-05 00:36:01.694976+07	2025-11-05 00:37:01.827929+07	2025-11-05 00:38:01.694976+07	f	\N	2025-11-07 21:37:20.719638+07
7a1b91cb-33cb-4356-b2a2-f66673da1462	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:09:01.241595+07	2025-11-05 00:09:02.285067+07	\N	2025-11-04 17:09:00	00:15:00	2025-11-05 00:08:02.241595+07	2025-11-05 00:09:02.367622+07	2025-11-05 00:10:01.241595+07	f	\N	2025-11-07 21:37:20.719638+07
2732f786-9937-41d5-9bda-13a81a2f012b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:36:02.587568+07	2025-11-05 00:37:02.492322+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:34:02.587568+07	2025-11-05 00:37:02.520162+07	2025-11-05 00:44:02.587568+07	f	\N	2025-11-07 21:37:20.719638+07
bc95cfdd-6277-40fd-b293-ea2572e81771	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:10:01.354937+07	2025-11-05 00:10:02.438916+07	\N	2025-11-04 17:10:00	00:15:00	2025-11-05 00:09:02.354937+07	2025-11-05 00:10:02.536903+07	2025-11-05 00:11:01.354937+07	f	\N	2025-11-07 21:37:20.719638+07
42fd76a1-2fda-48a2-9731-26d775dbe65c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:38:01.822363+07	2025-11-05 00:38:01.859486+07	\N	2025-11-04 17:38:00	00:15:00	2025-11-05 00:37:01.822363+07	2025-11-05 00:38:01.874165+07	2025-11-05 00:39:01.822363+07	f	\N	2025-11-07 21:37:20.719638+07
c00893b7-c4bc-44e7-88e3-0c72b55b52fe	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:11:01.507301+07	2025-11-05 00:11:02.568877+07	\N	2025-11-04 17:11:00	00:15:00	2025-11-05 00:10:02.507301+07	2025-11-05 00:11:02.579516+07	2025-11-05 00:12:01.507301+07	f	\N	2025-11-07 21:37:20.719638+07
b8fe772b-dd63-416d-9adf-86c936c8ddf8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:12:01.525505+07	2025-11-05 00:12:02.702529+07	\N	2025-11-04 17:12:00	00:15:00	2025-11-05 00:11:02.525505+07	2025-11-05 00:12:02.742001+07	2025-11-05 00:13:01.525505+07	f	\N	2025-11-07 21:37:20.719638+07
e1398598-4bdf-47c0-b328-4319f77d18e7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:39:01.869609+07	2025-11-05 00:39:01.97078+07	\N	2025-11-04 17:39:00	00:15:00	2025-11-05 00:38:01.869609+07	2025-11-05 00:39:02.092696+07	2025-11-05 00:40:01.869609+07	f	\N	2025-11-07 21:37:20.719638+07
172c6cd7-6745-48f4-b39a-e0238aacd49f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:13:02.240776+07	2025-11-05 00:13:02.562529+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:11:02.240776+07	2025-11-05 00:13:02.823175+07	2025-11-05 00:21:02.240776+07	f	\N	2025-11-07 21:37:20.719638+07
8e672065-514a-4bb1-9ee4-9e2da04db8c5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:40:01.071867+07	2025-11-05 00:40:02.105553+07	\N	2025-11-04 17:40:00	00:15:00	2025-11-05 00:39:02.071867+07	2025-11-05 00:40:02.12736+07	2025-11-05 00:41:01.071867+07	f	\N	2025-11-07 21:37:20.719638+07
fd26eaaa-6b02-459d-8f42-26f2c7c4a5b7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:13:01.72259+07	2025-11-05 00:13:02.88878+07	\N	2025-11-04 17:13:00	00:15:00	2025-11-05 00:12:02.72259+07	2025-11-05 00:13:02.904268+07	2025-11-05 00:14:01.72259+07	f	\N	2025-11-07 21:37:20.719638+07
0562d41d-d3c2-4e31-9085-770562873efa	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:39:02.524795+07	2025-11-05 00:40:02.51284+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:37:02.524795+07	2025-11-05 00:40:02.544546+07	2025-11-05 00:47:02.524795+07	f	\N	2025-11-07 21:37:20.719638+07
3046ff67-d88e-4801-a0a9-462293d5230b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:14:01.901277+07	2025-11-05 00:14:03.007846+07	\N	2025-11-04 17:14:00	00:15:00	2025-11-05 00:13:02.901277+07	2025-11-05 00:14:03.023398+07	2025-11-05 00:15:01.901277+07	f	\N	2025-11-07 21:37:20.719638+07
c134357c-1593-4cfc-84d6-73883dcb1394	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:15:01.020985+07	2025-11-05 00:15:03.154995+07	\N	2025-11-04 17:15:00	00:15:00	2025-11-05 00:14:03.020985+07	2025-11-05 00:15:03.165646+07	2025-11-05 00:16:01.020985+07	f	\N	2025-11-07 21:37:20.719638+07
446cbeaf-bd70-43d0-bbb6-8e4b71809fe5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:42:02.550466+07	2025-11-05 00:43:02.537636+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:40:02.550466+07	2025-11-05 00:43:02.638713+07	2025-11-05 00:50:02.550466+07	f	\N	2025-11-07 21:37:20.719638+07
f1b3dea3-6433-4edd-b095-57c2bb3d5d38	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:15:02.831439+07	2025-11-05 00:16:02.250359+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:13:02.831439+07	2025-11-05 00:16:02.2811+07	2025-11-05 00:23:02.831439+07	f	\N	2025-11-07 21:37:20.719638+07
3f9224ce-b283-4e7a-9e30-f99fc7d60e01	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:16:01.163055+07	2025-11-05 00:16:03.27835+07	\N	2025-11-04 17:16:00	00:15:00	2025-11-05 00:15:03.163055+07	2025-11-05 00:16:03.288659+07	2025-11-05 00:17:01.163055+07	f	\N	2025-11-07 21:37:20.719638+07
5061b718-7d2b-41ab-92ea-a7a30e10f9b7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:17:01.286172+07	2025-11-05 00:17:03.389289+07	\N	2025-11-04 17:17:00	00:15:00	2025-11-05 00:16:03.286172+07	2025-11-05 00:17:03.401327+07	2025-11-05 00:18:01.286172+07	f	\N	2025-11-07 21:37:20.719638+07
81beb6d9-568f-41dc-b5aa-96f671b6fa7d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:18:01.397837+07	2025-11-05 00:18:03.487923+07	\N	2025-11-04 17:18:00	00:15:00	2025-11-05 00:17:03.397837+07	2025-11-05 00:18:03.498212+07	2025-11-05 00:19:01.397837+07	f	\N	2025-11-07 21:37:20.719638+07
85c44c25-fd6b-44b0-bde6-9ba302c42b42	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:18:02.285075+07	2025-11-05 00:19:02.272594+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:16:02.285075+07	2025-11-05 00:19:02.290408+07	2025-11-05 00:26:02.285075+07	f	\N	2025-11-07 21:37:20.719638+07
7b510a47-6c01-4c6b-b699-6718a5f7d813	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:19:01.495342+07	2025-11-05 00:19:03.590888+07	\N	2025-11-04 17:19:00	00:15:00	2025-11-05 00:18:03.495342+07	2025-11-05 00:19:03.602588+07	2025-11-05 00:20:01.495342+07	f	\N	2025-11-07 21:37:20.719638+07
cbbc5a9f-e16d-44c3-866c-07bc06e6c96d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:20:01.599977+07	2025-11-05 00:20:03.690953+07	\N	2025-11-04 17:20:00	00:15:00	2025-11-05 00:19:03.599977+07	2025-11-05 00:20:03.706974+07	2025-11-05 00:21:01.599977+07	f	\N	2025-11-07 21:37:20.719638+07
dbf7fed9-0d72-4f72-b232-68a8a6073706	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:21:01.703247+07	2025-11-05 00:21:03.788373+07	\N	2025-11-04 17:21:00	00:15:00	2025-11-05 00:20:03.703247+07	2025-11-05 00:21:03.839502+07	2025-11-05 00:22:01.703247+07	f	\N	2025-11-07 21:37:20.719638+07
f34d9828-ce39-4f15-a9b9-28dbaf52b2ed	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:21:02.294557+07	2025-11-05 00:22:02.292501+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:19:02.294557+07	2025-11-05 00:22:02.40314+07	2025-11-05 00:29:02.294557+07	f	\N	2025-11-07 21:37:20.719638+07
2f7ab30e-23c6-45bd-9268-28e6b874d249	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:22:01.833961+07	2025-11-05 00:22:03.921143+07	\N	2025-11-04 17:22:00	00:15:00	2025-11-05 00:21:03.833961+07	2025-11-05 00:22:04.017086+07	2025-11-05 00:23:01.833961+07	f	\N	2025-11-07 21:37:20.719638+07
bea95af7-249d-483b-a9eb-123c35c4da74	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:23:01.014345+07	2025-11-05 00:23:04.05378+07	\N	2025-11-04 17:23:00	00:15:00	2025-11-05 00:22:04.014345+07	2025-11-05 00:23:04.09132+07	2025-11-05 00:24:01.014345+07	f	\N	2025-11-07 21:37:20.719638+07
d1ebbe60-dd7b-4614-afa3-1facf2441069	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:24:01.080671+07	2025-11-05 00:24:04.142952+07	\N	2025-11-04 17:24:00	00:15:00	2025-11-05 00:23:04.080671+07	2025-11-05 00:24:04.152365+07	2025-11-05 00:25:01.080671+07	f	\N	2025-11-07 21:37:20.719638+07
690fb761-c21d-4d74-8b00-bf7cf73b117d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:24:02.414365+07	2025-11-05 00:25:02.311994+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:22:02.414365+07	2025-11-05 00:25:02.375522+07	2025-11-05 00:32:02.414365+07	f	\N	2025-11-07 21:37:20.719638+07
6a92972d-3e61-4dc2-bd63-86137fa4ed90	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:25:01.150207+07	2025-11-05 00:25:04.24458+07	\N	2025-11-04 17:25:00	00:15:00	2025-11-05 00:24:04.150207+07	2025-11-05 00:25:04.258265+07	2025-11-05 00:26:01.150207+07	f	\N	2025-11-07 21:37:20.719638+07
5a8cb96f-68d5-4203-85c1-a2d751f8af1a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:26:01.254033+07	2025-11-05 00:26:04.370976+07	\N	2025-11-04 17:26:00	00:15:00	2025-11-05 00:25:04.254033+07	2025-11-05 00:26:04.422479+07	2025-11-05 00:27:01.254033+07	f	\N	2025-11-07 21:37:20.719638+07
3cefc0d2-b130-4bf3-890e-a34f4e590f28	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:27:01.412273+07	2025-11-05 00:27:04.484883+07	\N	2025-11-04 17:27:00	00:15:00	2025-11-05 00:26:04.412273+07	2025-11-05 00:27:04.495716+07	2025-11-05 00:28:01.412273+07	f	\N	2025-11-07 21:37:20.719638+07
90f9f560-cdf7-4709-aabf-5021e651c054	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:27:02.390102+07	2025-11-05 00:28:02.324559+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:25:02.390102+07	2025-11-05 00:28:02.353953+07	2025-11-05 00:35:02.390102+07	f	\N	2025-11-07 21:37:20.719638+07
abb7ce3f-28d4-45f8-a335-7fdafcb142be	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:28:01.492525+07	2025-11-05 00:28:04.610465+07	\N	2025-11-04 17:28:00	00:15:00	2025-11-05 00:27:04.492525+07	2025-11-05 00:28:04.620015+07	2025-11-05 00:29:01.492525+07	f	\N	2025-11-07 21:37:20.719638+07
48dce7ab-a975-487d-962d-5e52588229ef	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:29:01.617898+07	2025-11-05 00:29:04.722188+07	\N	2025-11-04 17:29:00	00:15:00	2025-11-05 00:28:04.617898+07	2025-11-05 00:29:04.738556+07	2025-11-05 00:30:01.617898+07	f	\N	2025-11-07 21:37:20.719638+07
3ea87fb0-91a5-4739-a0c1-cbd8a2143e32	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:30:01.735252+07	2025-11-05 00:30:04.865289+07	\N	2025-11-04 17:30:00	00:15:00	2025-11-05 00:29:04.735252+07	2025-11-05 00:30:04.88259+07	2025-11-05 00:31:01.735252+07	f	\N	2025-11-07 21:37:20.719638+07
67faf1da-c3e0-4b36-a713-6a46ad37e805	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:30:02.361304+07	2025-11-05 00:31:02.361621+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:28:02.361304+07	2025-11-05 00:31:02.394885+07	2025-11-05 00:38:02.361304+07	f	\N	2025-11-07 21:37:20.719638+07
ba98e34d-3609-443c-9426-be29c22a462c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:31:01.87811+07	2025-11-05 00:31:04.981436+07	\N	2025-11-04 17:31:00	00:15:00	2025-11-05 00:30:04.87811+07	2025-11-05 00:31:04.994144+07	2025-11-05 00:32:01.87811+07	f	\N	2025-11-07 21:37:20.719638+07
cde7cbd2-6e2c-4c23-86b6-7d6340f5cd96	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:32:01.991513+07	2025-11-05 00:32:05.106997+07	\N	2025-11-04 17:32:00	00:15:00	2025-11-05 00:31:04.991513+07	2025-11-05 00:32:05.125961+07	2025-11-05 00:33:01.991513+07	f	\N	2025-11-07 21:37:20.719638+07
be860a98-d034-4c49-938c-059d5a8a7b62	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:33:01.122351+07	2025-11-05 00:33:01.232112+07	\N	2025-11-04 17:33:00	00:15:00	2025-11-05 00:32:05.122351+07	2025-11-05 00:33:01.258657+07	2025-11-05 00:34:01.122351+07	f	\N	2025-11-07 21:37:20.719638+07
36d40d77-d0a7-4c3f-beeb-21b7d2a800a9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:34:01.254245+07	2025-11-05 00:34:02.065586+07	\N	2025-11-04 17:34:00	00:15:00	2025-11-05 00:33:01.254245+07	2025-11-05 00:34:02.195216+07	2025-11-05 00:35:01.254245+07	f	\N	2025-11-07 21:37:20.719638+07
cdade89d-2402-4983-a13d-9521a0f04f29	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:33:02.400411+07	2025-11-05 00:34:02.460344+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:31:02.400411+07	2025-11-05 00:34:02.583224+07	2025-11-05 00:41:02.400411+07	f	\N	2025-11-07 21:37:20.719638+07
165c9fda-5d2f-475c-9851-4949a7849a0a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:35:01.18582+07	2025-11-05 00:35:01.548094+07	\N	2025-11-04 17:35:00	00:15:00	2025-11-05 00:34:02.18582+07	2025-11-05 00:35:01.573064+07	2025-11-05 00:36:01.18582+07	f	\N	2025-11-07 21:37:20.719638+07
d95e3034-8c5b-43db-a018-fb6e932d560c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:41:01.123804+07	2025-11-05 00:41:02.213084+07	\N	2025-11-04 17:41:00	00:15:00	2025-11-05 00:40:02.123804+07	2025-11-05 00:41:02.269992+07	2025-11-05 00:42:01.123804+07	f	\N	2025-11-07 21:37:20.719638+07
b6f847f1-8f7e-4606-88b3-9901e99d7948	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:11:01.511405+07	2025-11-05 01:11:03.024579+07	\N	2025-11-04 18:11:00	00:15:00	2025-11-05 01:10:06.511405+07	2025-11-05 01:11:03.051947+07	2025-11-05 01:12:01.511405+07	f	\N	2025-11-07 21:37:20.719638+07
320086e9-4c1b-4eab-b09b-5d4986aa0b2e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:42:01.259445+07	2025-11-05 00:42:02.326953+07	\N	2025-11-04 17:42:00	00:15:00	2025-11-05 00:41:02.259445+07	2025-11-05 00:42:02.339783+07	2025-11-05 00:43:01.259445+07	f	\N	2025-11-07 21:37:20.719638+07
725287ab-489d-478a-a70d-8caa78ec771a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:43:01.336524+07	2025-11-05 00:43:02.460635+07	\N	2025-11-04 17:43:00	00:15:00	2025-11-05 00:42:02.336524+07	2025-11-05 00:43:02.474925+07	2025-11-05 00:44:01.336524+07	f	\N	2025-11-07 21:37:20.719638+07
0f634307-4bd2-44b6-bbfc-6e6c6f780069	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:14:01.268885+07	2025-11-05 01:14:03.579715+07	\N	2025-11-04 18:14:00	00:15:00	2025-11-05 01:13:03.268885+07	2025-11-05 01:14:03.602373+07	2025-11-05 01:15:01.268885+07	f	\N	2025-11-07 21:37:20.719638+07
63a2e652-3a03-49f0-aaaa-8c505c7fdc2c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:44:01.471407+07	2025-11-05 00:44:02.589078+07	\N	2025-11-04 17:44:00	00:15:00	2025-11-05 00:43:02.471407+07	2025-11-05 00:44:02.618106+07	2025-11-05 00:45:01.471407+07	f	\N	2025-11-07 21:37:20.719638+07
8f97a6f7-2381-421f-9170-09220636e53d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:15:01.711523+07	2025-11-05 01:15:02.012435+07	\N	2025-11-04 18:15:00	00:15:00	2025-11-05 01:14:03.711523+07	2025-11-05 01:15:02.065776+07	2025-11-05 01:16:01.711523+07	f	\N	2025-11-07 21:37:20.719638+07
51eab033-e917-433c-8136-03aa38e188fc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:45:01.611476+07	2025-11-05 00:45:02.725107+07	\N	2025-11-04 17:45:00	00:15:00	2025-11-05 00:44:02.611476+07	2025-11-05 00:45:02.780356+07	2025-11-05 00:46:01.611476+07	f	\N	2025-11-07 21:37:20.719638+07
a731a4c3-2f12-4b63-97e1-bffe9ae2e2e9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:45:02.644653+07	2025-11-05 00:46:02.560297+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:43:02.644653+07	2025-11-05 00:46:02.598883+07	2025-11-05 00:53:02.644653+07	f	\N	2025-11-07 21:37:20.719638+07
bf9bbdbf-2084-451d-a760-633d0e0b06ed	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:46:01.771315+07	2025-11-05 00:46:02.824462+07	\N	2025-11-04 17:46:00	00:15:00	2025-11-05 00:45:02.771315+07	2025-11-05 00:46:02.833259+07	2025-11-05 00:47:01.771315+07	f	\N	2025-11-07 21:37:20.719638+07
a0d57aaa-5ef4-4bc5-a029-2556aeba1568	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:47:01.796834+07	2025-11-05 00:47:02.920312+07	\N	2025-11-04 17:47:00	00:15:00	2025-11-05 00:46:02.796834+07	2025-11-05 00:47:02.933267+07	2025-11-05 00:48:01.796834+07	f	\N	2025-11-07 21:37:20.719638+07
40056a29-4a6a-4390-914a-44bec2d203f1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:48:01.929451+07	2025-11-05 00:48:03.050313+07	\N	2025-11-04 17:48:00	00:15:00	2025-11-05 00:47:02.929451+07	2025-11-05 00:48:03.06143+07	2025-11-05 00:49:01.929451+07	f	\N	2025-11-07 21:37:20.719638+07
be159155-bbf3-444d-a3f1-29fa13cafbfb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:48:02.60744+07	2025-11-05 00:49:02.580621+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:46:02.60744+07	2025-11-05 00:49:02.667655+07	2025-11-05 00:56:02.60744+07	f	\N	2025-11-07 21:37:20.719638+07
980d3efa-f139-4350-b843-c61a7b006b78	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:49:01.058135+07	2025-11-05 00:49:03.193392+07	\N	2025-11-04 17:49:00	00:15:00	2025-11-05 00:48:03.058135+07	2025-11-05 00:49:03.207131+07	2025-11-05 00:50:01.058135+07	f	\N	2025-11-07 21:37:20.719638+07
aacb8441-90b3-4d20-a89c-1a2da2e8786d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:50:01.205177+07	2025-11-05 00:50:03.297321+07	\N	2025-11-04 17:50:00	00:15:00	2025-11-05 00:49:03.205177+07	2025-11-05 00:50:03.3184+07	2025-11-05 00:51:01.205177+07	f	\N	2025-11-07 21:37:20.719638+07
9e2ee305-b8b3-4aa1-85c0-aaba998553df	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:51:01.314982+07	2025-11-05 00:51:03.418873+07	\N	2025-11-04 17:51:00	00:15:00	2025-11-05 00:50:03.314982+07	2025-11-05 00:51:03.467848+07	2025-11-05 00:52:01.314982+07	f	\N	2025-11-07 21:37:20.719638+07
d94edbdc-3076-4358-a9a3-32741df53071	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:51:02.674596+07	2025-11-05 00:52:02.605952+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:49:02.674596+07	2025-11-05 00:52:02.721731+07	2025-11-05 00:59:02.674596+07	f	\N	2025-11-07 21:37:20.719638+07
62ac1708-662b-437a-af54-d849ae19c6dd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:52:01.460445+07	2025-11-05 00:52:03.624915+07	\N	2025-11-04 17:52:00	00:15:00	2025-11-05 00:51:03.460445+07	2025-11-05 00:52:03.675108+07	2025-11-05 00:53:01.460445+07	f	\N	2025-11-07 21:37:20.719638+07
2f8cee7e-32b6-4641-b23a-6a5d1dd86f7c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:53:01.667974+07	2025-11-05 00:53:03.757572+07	\N	2025-11-04 17:53:00	00:15:00	2025-11-05 00:52:03.667974+07	2025-11-05 00:53:03.770961+07	2025-11-05 00:54:01.667974+07	f	\N	2025-11-07 21:37:20.719638+07
7a9548e0-d72a-41ba-914f-79d0deb09da0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:54:01.768212+07	2025-11-05 00:54:03.892137+07	\N	2025-11-04 17:54:00	00:15:00	2025-11-05 00:53:03.768212+07	2025-11-05 00:54:03.905551+07	2025-11-05 00:55:01.768212+07	f	\N	2025-11-07 21:37:20.719638+07
545df2a8-c260-462a-92e9-73db5ef2f230	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:54:02.734393+07	2025-11-05 00:55:02.634498+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:52:02.734393+07	2025-11-05 00:55:02.657796+07	2025-11-05 01:02:02.734393+07	f	\N	2025-11-07 21:37:20.719638+07
12eae5c6-f683-4d6f-ac6b-94ea503f51ed	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:55:01.902842+07	2025-11-05 00:55:04.028103+07	\N	2025-11-04 17:55:00	00:15:00	2025-11-05 00:54:03.902842+07	2025-11-05 00:55:04.035987+07	2025-11-05 00:56:01.902842+07	f	\N	2025-11-07 21:37:20.719638+07
0925e6d1-a1ac-488a-8513-643633535a7d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:56:01.033532+07	2025-11-05 00:56:04.134311+07	\N	2025-11-04 17:56:00	00:15:00	2025-11-05 00:55:04.033532+07	2025-11-05 00:56:04.154546+07	2025-11-05 00:57:01.033532+07	f	\N	2025-11-07 21:37:20.719638+07
19db1a53-39f0-4d16-aba3-4014aa7982d7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:57:01.149708+07	2025-11-05 00:57:04.24447+07	\N	2025-11-04 17:57:00	00:15:00	2025-11-05 00:56:04.149708+07	2025-11-05 00:57:04.261249+07	2025-11-05 00:58:01.149708+07	f	\N	2025-11-07 21:37:20.719638+07
70fb7644-1be6-4820-b986-a1193737b463	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 00:57:02.662775+07	2025-11-05 00:58:02.672967+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:55:02.662775+07	2025-11-05 00:58:02.701334+07	2025-11-05 01:05:02.662775+07	f	\N	2025-11-07 21:37:20.719638+07
b46aa1d1-79a5-4634-bf60-11867898d02a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:58:01.257278+07	2025-11-05 00:58:04.371523+07	\N	2025-11-04 17:58:00	00:15:00	2025-11-05 00:57:04.257278+07	2025-11-05 00:58:04.409509+07	2025-11-05 00:59:01.257278+07	f	\N	2025-11-07 21:37:20.719638+07
c86d39ef-b324-4443-b4a3-f79e91ba21c0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 00:59:01.403776+07	2025-11-05 00:59:04.607962+07	\N	2025-11-04 17:59:00	00:15:00	2025-11-05 00:58:04.403776+07	2025-11-05 00:59:04.623565+07	2025-11-05 01:00:01.403776+07	f	\N	2025-11-07 21:37:20.719638+07
7f9ab87b-8b8a-46c4-993a-046aa818a49e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:00:01.621165+07	2025-11-05 01:00:04.755243+07	\N	2025-11-04 18:00:00	00:15:00	2025-11-05 00:59:04.621165+07	2025-11-05 01:00:04.762545+07	2025-11-05 01:01:01.621165+07	f	\N	2025-11-07 21:37:20.719638+07
81330e99-5cee-4e91-a8b6-988886b38255	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:00:02.706499+07	2025-11-05 01:01:02.690245+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 00:58:02.706499+07	2025-11-05 01:01:02.700881+07	2025-11-05 01:08:02.706499+07	f	\N	2025-11-07 21:37:20.719638+07
0b613bcd-0c22-47ca-9328-2f0cacd8c121	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:01:01.760687+07	2025-11-05 01:01:04.857223+07	\N	2025-11-04 18:01:00	00:15:00	2025-11-05 01:00:04.760687+07	2025-11-05 01:01:04.865702+07	2025-11-05 01:02:01.760687+07	f	\N	2025-11-07 21:37:20.719638+07
7a01c58d-21d0-4b64-a1fa-1c7bade4bf08	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:02:01.864116+07	2025-11-05 01:02:04.969224+07	\N	2025-11-04 18:02:00	00:15:00	2025-11-05 01:01:04.864116+07	2025-11-05 01:02:04.978617+07	2025-11-05 01:03:01.864116+07	f	\N	2025-11-07 21:37:20.719638+07
711bfc36-4030-45d4-b861-028b5c415890	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:03:02.703649+07	2025-11-05 01:03:02.706439+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:01:02.703649+07	2025-11-05 01:03:02.72524+07	2025-11-05 01:11:02.703649+07	f	\N	2025-11-07 21:37:20.719638+07
adaa04fc-0f2e-4218-a7bc-9f0d6a4364b9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:03:01.975386+07	2025-11-05 01:03:05.071443+07	\N	2025-11-04 18:03:00	00:15:00	2025-11-05 01:02:04.975386+07	2025-11-05 01:03:05.091126+07	2025-11-05 01:04:01.975386+07	f	\N	2025-11-07 21:37:20.719638+07
71a5c195-e085-4ce6-bfd6-a0441cccfdb7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:04:01.087969+07	2025-11-05 01:04:01.207286+07	\N	2025-11-04 18:04:00	00:15:00	2025-11-05 01:03:05.087969+07	2025-11-05 01:04:01.223012+07	2025-11-05 01:05:01.087969+07	f	\N	2025-11-07 21:37:20.719638+07
dbefc38a-6416-4bab-b96e-4bfa341391a8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:05:01.219261+07	2025-11-05 01:05:01.292888+07	\N	2025-11-04 18:05:00	00:15:00	2025-11-05 01:04:01.219261+07	2025-11-05 01:05:01.302347+07	2025-11-05 01:06:01.219261+07	f	\N	2025-11-07 21:37:20.719638+07
699d5a7a-c85d-445a-a754-361ac038771d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:06:01.300139+07	2025-11-05 01:06:01.421518+07	\N	2025-11-04 18:06:00	00:15:00	2025-11-05 01:05:01.300139+07	2025-11-05 01:06:01.432568+07	2025-11-05 01:07:01.300139+07	f	\N	2025-11-07 21:37:20.719638+07
fa02d474-a71e-4d04-a7ec-5fb383ccf87e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:05:02.727719+07	2025-11-05 01:06:02.734749+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:03:02.727719+07	2025-11-05 01:06:02.74753+07	2025-11-05 01:13:02.727719+07	f	\N	2025-11-07 21:37:20.719638+07
0fbd6393-cacb-4c9d-94b1-576a9891897b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:07:01.429987+07	2025-11-05 01:07:01.519636+07	\N	2025-11-04 18:07:00	00:15:00	2025-11-05 01:06:01.429987+07	2025-11-05 01:07:01.531425+07	2025-11-05 01:08:01.429987+07	f	\N	2025-11-07 21:37:20.719638+07
3d19d782-a485-4750-9d21-06f1d942d221	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:08:01.528347+07	2025-11-05 01:08:01.648376+07	\N	2025-11-04 18:08:00	00:15:00	2025-11-05 01:07:01.528347+07	2025-11-05 01:08:01.67104+07	2025-11-05 01:09:01.528347+07	f	\N	2025-11-07 21:37:20.719638+07
d65655bb-095f-4c67-aa9d-7b09883299cd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:09:36.435125+07	2025-11-05 01:09:36.458099+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:09:36.435125+07	2025-11-05 01:09:36.493841+07	2025-11-05 01:17:36.435125+07	f	\N	2025-11-07 21:37:20.719638+07
744dfb0c-8cb2-480e-85ab-8869cee105cb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:09:01.66792+07	2025-11-05 01:09:36.59582+07	\N	2025-11-04 18:09:00	00:15:00	2025-11-05 01:08:01.66792+07	2025-11-05 01:09:36.6261+07	2025-11-05 01:10:01.66792+07	f	\N	2025-11-07 21:37:20.719638+07
7bffc948-f86d-454e-9f21-9af2d2ba23c3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:09:47.543892+07	2025-11-05 01:09:47.553726+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:09:47.543892+07	2025-11-05 01:09:47.587032+07	2025-11-05 01:17:47.543892+07	f	\N	2025-11-07 21:37:20.719638+07
0493e023-fdd4-401b-a1da-26afb11afb98	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:10:06.208531+07	2025-11-05 01:10:06.223268+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:10:06.208531+07	2025-11-05 01:10:06.25297+07	2025-11-05 01:18:06.208531+07	f	\N	2025-11-07 21:37:20.719638+07
948fae8d-c745-48a0-9f4d-60d53939e3c6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:10:01.745428+07	2025-11-05 01:10:06.360802+07	\N	2025-11-04 18:10:00	00:15:00	2025-11-05 01:09:36.745428+07	2025-11-05 01:10:06.384273+07	2025-11-05 01:11:01.745428+07	f	\N	2025-11-07 21:37:20.719638+07
276c1ab0-60b0-4a4a-bdb2-952ad760936f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:10:26.616824+07	2025-11-05 01:10:26.629344+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:10:26.616824+07	2025-11-05 01:10:26.660181+07	2025-11-05 01:18:26.616824+07	f	\N	2025-11-07 21:37:20.719638+07
22aa2aea-297a-4340-8a49-0e59357fdedc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:27:35.331724+07	2025-11-05 01:27:35.349042+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:27:35.331724+07	2025-11-05 01:27:35.382558+07	2025-11-05 01:35:35.331724+07	f	\N	2025-11-07 21:37:20.719638+07
0b7a48c4-8482-435c-b5df-a4412381df2b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:12:26.666169+07	2025-11-05 01:13:26.632534+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:10:26.666169+07	2025-11-05 01:13:26.669665+07	2025-11-05 01:20:26.666169+07	f	\N	2025-11-07 21:37:20.719638+07
8895860e-d20c-4a10-a0f2-f4be4bd28d26	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:57:01.230256+07	2025-11-05 01:57:02.341638+07	\N	2025-11-04 18:57:00	00:15:00	2025-11-05 01:56:02.230256+07	2025-11-05 01:57:02.367842+07	2025-11-05 01:58:01.230256+07	f	\N	2025-11-07 21:37:20.719638+07
e76157e4-3c2e-4ab8-a5ff-252a80f2b712	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:34:32.934757+07	2025-11-05 02:34:32.944098+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:34:32.934757+07	2025-11-05 02:34:32.973137+07	2025-11-05 02:42:32.934757+07	f	\N	2025-11-07 21:37:20.719638+07
89479105-79dd-4130-a567-8a9d2645602c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:14:03.31411+07	2025-11-05 01:14:03.324354+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:14:03.31411+07	2025-11-05 01:14:03.353719+07	2025-11-05 01:22:03.31411+07	f	\N	2025-11-07 21:37:20.719638+07
df42b134-3cec-4a6a-b036-f0c89e93586c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:28:20.077636+07	2025-11-05 01:28:20.090879+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:28:20.077636+07	2025-11-05 01:28:20.127647+07	2025-11-05 01:36:20.077636+07	f	\N	2025-11-07 21:37:20.719638+07
a51d34e9-27b7-437d-898e-2a5ff580357e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:14:32.869762+07	2025-11-05 01:14:32.879967+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:14:32.869762+07	2025-11-05 01:14:32.907985+07	2025-11-05 01:22:32.869762+07	f	\N	2025-11-07 21:37:20.719638+07
d78a1340-252f-453b-b4c6-dc0b262020de	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:30:20.133589+07	2025-11-05 01:31:20.112661+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:28:20.133589+07	2025-11-05 01:31:20.176614+07	2025-11-05 01:38:20.133589+07	f	\N	2025-11-07 21:37:20.719638+07
4c617237-1a7f-4ff1-b8c0-f7656ce3d46d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:15:01.25486+07	2025-11-05 01:15:01.271226+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:15:01.25486+07	2025-11-05 01:15:01.340861+07	2025-11-05 01:23:01.25486+07	f	\N	2025-11-07 21:37:20.719638+07
f4f57df5-c3bb-4382-8818-3658482bdbdf	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:31:47.159514+07	2025-11-05 01:31:47.168476+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:31:47.159514+07	2025-11-05 01:31:47.195115+07	2025-11-05 01:39:47.159514+07	f	\N	2025-11-07 21:37:20.719638+07
181336f0-c7a0-40c1-9a6d-d04837db32d7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:15:11.263845+07	2025-11-05 01:15:11.279836+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:15:11.263845+07	2025-11-05 01:15:11.31348+07	2025-11-05 01:23:11.263845+07	f	\N	2025-11-07 21:37:20.719638+07
5a777f0a-aaa8-480f-997c-4078c3df3278	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:34:01.497716+07	2025-11-05 01:34:03.602634+07	\N	2025-11-04 18:34:00	00:15:00	2025-11-05 01:33:03.497716+07	2025-11-05 01:34:03.615613+07	2025-11-05 01:35:01.497716+07	f	\N	2025-11-07 21:37:20.719638+07
040dc004-8fd0-4f1a-9d9f-78cc03817e97	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:15:29.791633+07	2025-11-05 01:15:29.80156+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:15:29.791633+07	2025-11-05 01:15:29.82814+07	2025-11-05 01:23:29.791633+07	f	\N	2025-11-07 21:37:20.719638+07
831bcaa3-3594-4ada-96a9-997c459482fd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:33:47.19935+07	2025-11-05 01:34:47.184428+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:31:47.19935+07	2025-11-05 01:34:47.201057+07	2025-11-05 01:41:47.19935+07	f	\N	2025-11-07 21:37:20.719638+07
0bc9d390-ed3e-4a0e-9cb4-3d142f0e1508	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:35:01.612799+07	2025-11-05 01:35:03.709188+07	\N	2025-11-04 18:35:00	00:15:00	2025-11-05 01:34:03.612799+07	2025-11-05 01:35:03.718003+07	2025-11-05 01:36:01.612799+07	f	\N	2025-11-07 21:37:20.719638+07
5c766147-c436-44c2-a1dc-3d28887baa6d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:38:01.004809+07	2025-11-05 01:38:04.130098+07	\N	2025-11-04 18:38:00	00:15:00	2025-11-05 01:37:04.004809+07	2025-11-05 01:38:04.142304+07	2025-11-05 01:39:01.004809+07	f	\N	2025-11-07 21:37:20.719638+07
b939e190-8bab-42df-afff-76bb908cc857	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:39:47.206146+07	2025-11-05 01:40:47.207206+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:37:47.206146+07	2025-11-05 01:40:47.21812+07	2025-11-05 01:47:47.206146+07	f	\N	2025-11-07 21:37:20.719638+07
426a4050-6a6f-4273-823a-70a15df4573e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:42:01.486135+07	2025-11-05 01:42:04.589196+07	\N	2025-11-04 18:42:00	00:15:00	2025-11-05 01:41:04.486135+07	2025-11-05 01:42:04.607105+07	2025-11-05 01:43:01.486135+07	f	\N	2025-11-07 21:37:20.719638+07
97b3466b-7301-4f75-be74-d468bd5a89de	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:43:01.601519+07	2025-11-05 01:43:04.71685+07	\N	2025-11-04 18:43:00	00:15:00	2025-11-05 01:42:04.601519+07	2025-11-05 01:43:04.725911+07	2025-11-05 01:44:01.601519+07	f	\N	2025-11-07 21:37:20.719638+07
acf85493-695b-4bf3-9899-f39e57074fc1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:42:47.221819+07	2025-11-05 01:43:47.234269+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:40:47.221819+07	2025-11-05 01:43:47.243985+07	2025-11-05 01:50:47.221819+07	f	\N	2025-11-07 21:37:20.719638+07
1339a731-8da0-4f35-8e6a-0bdb4a608501	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:44:01.723671+07	2025-11-05 01:44:04.851264+07	\N	2025-11-04 18:44:00	00:15:00	2025-11-05 01:43:04.723671+07	2025-11-05 01:44:04.861831+07	2025-11-05 01:45:01.723671+07	f	\N	2025-11-07 21:37:20.719638+07
145bce32-366d-463f-bdc7-aa6a8fa633b9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:45:01.859428+07	2025-11-05 01:45:05.018805+07	\N	2025-11-04 18:45:00	00:15:00	2025-11-05 01:44:04.859428+07	2025-11-05 01:45:05.032242+07	2025-11-05 01:46:01.859428+07	f	\N	2025-11-07 21:37:20.719638+07
8cb69831-716c-4a34-a890-84834d6a2e9d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:45:47.246383+07	2025-11-05 01:45:47.24965+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:43:47.246383+07	2025-11-05 01:45:47.261804+07	2025-11-05 01:53:47.246383+07	f	\N	2025-11-07 21:37:20.719638+07
34738a3d-ad3d-416f-a2a3-db66d185668f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:46:01.029596+07	2025-11-05 01:46:01.111131+07	\N	2025-11-04 18:46:00	00:15:00	2025-11-05 01:45:05.029596+07	2025-11-05 01:46:01.12303+07	2025-11-05 01:47:01.029596+07	f	\N	2025-11-07 21:37:20.719638+07
0e770db6-5299-4495-9b0b-6f69ba29d4b2	xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762281917458-Tong hop NB.2021-2025.IN.xlsx", "userId": 5, "template": "excel2", "modelName": "cobia_xgboost", "originalname": "Tong hop NB.2021-2025.IN.xlsx"}	completed	3	0	60000	f	2025-11-05 01:45:17.479219+07	2025-11-05 01:45:18.591012+07	\N	\N	00:15:00	2025-11-05 01:45:17.479219+07	2025-11-05 01:46:46.281929+07	2025-11-19 01:45:17.479219+07	f	{"parsed": 32, "created": 32}	2025-11-07 21:37:20.719638+07
93a4d074-efee-431d-9c8c-21703037927f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:47:01.118437+07	2025-11-05 01:47:01.229439+07	\N	2025-11-04 18:47:00	00:15:00	2025-11-05 01:46:01.118437+07	2025-11-05 01:47:01.239316+07	2025-11-05 01:48:01.118437+07	f	\N	2025-11-07 21:37:20.719638+07
8a01189e-544b-4289-aabb-fe4c604c008e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:47:47.264468+07	2025-11-05 01:47:47.272434+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:45:47.264468+07	2025-11-05 01:47:47.298218+07	2025-11-05 01:55:47.264468+07	f	\N	2025-11-07 21:37:20.719638+07
3349984d-dc41-4972-aac2-fdbdc1a335d3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:47:57.312064+07	2025-11-05 01:47:57.327934+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:47:57.312064+07	2025-11-05 01:47:57.361237+07	2025-11-05 01:55:57.312064+07	f	\N	2025-11-07 21:37:20.719638+07
cdf70a86-1af5-4bd9-9817-27f2505acb10	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:48:01.236256+07	2025-11-05 01:48:01.588647+07	\N	2025-11-04 18:48:00	00:15:00	2025-11-05 01:47:01.236256+07	2025-11-05 01:48:01.606663+07	2025-11-05 01:49:01.236256+07	f	\N	2025-11-07 21:37:20.719638+07
dc50f67f-9295-4962-92ed-05fb910dbd28	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:48:06.698033+07	2025-11-05 01:48:06.709208+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:48:06.698033+07	2025-11-05 01:48:06.743629+07	2025-11-05 01:56:06.698033+07	f	\N	2025-11-07 21:37:20.719638+07
73969bae-db96-43c4-a575-2af7350140f3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:48:13.357248+07	2025-11-05 01:48:13.366329+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:48:13.357248+07	2025-11-05 01:48:13.392332+07	2025-11-05 01:56:13.357248+07	f	\N	2025-11-07 21:37:20.719638+07
dd3b771a-2427-4ea2-9545-831736cc15ea	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:48:37.576084+07	2025-11-05 01:48:37.588488+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:48:37.576084+07	2025-11-05 01:48:37.61833+07	2025-11-05 01:56:37.576084+07	f	\N	2025-11-07 21:37:20.719638+07
edc210d7-2ae6-4783-99e2-0985b94ea726	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:49:01.602446+07	2025-11-05 01:49:02.031972+07	\N	2025-11-04 18:49:00	00:15:00	2025-11-05 01:48:01.602446+07	2025-11-05 01:49:02.052526+07	2025-11-05 01:50:01.602446+07	f	\N	2025-11-07 21:37:20.719638+07
467e7cfb-04cd-4a0d-94ee-9ebbfdb71d7a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:50:01.04897+07	2025-11-05 01:50:02.141703+07	\N	2025-11-04 18:50:00	00:15:00	2025-11-05 01:49:02.04897+07	2025-11-05 01:50:02.1616+07	2025-11-05 01:51:01.04897+07	f	\N	2025-11-07 21:37:20.719638+07
707084e2-81a3-4dc0-a697-058cd7bb2c65	xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762282167427-Tong hop NB.2021-2025.IN.xlsx", "userId": 5, "template": "excel2", "modelName": "cobia_xgboost", "originalname": "Tong hop NB.2021-2025.IN.xlsx"}	completed	3	0	60000	f	2025-11-05 01:49:27.439252+07	2025-11-05 01:49:28.302613+07	\N	\N	00:15:00	2025-11-05 01:49:27.439252+07	2025-11-05 01:50:55.959107+07	2025-11-19 01:49:27.439252+07	f	{"parsed": 32, "created": 32}	2025-11-07 21:37:20.719638+07
b8d0b10e-2f39-40f6-81c1-5dc295a0b93f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:51:01.152725+07	2025-11-05 01:51:02.317513+07	\N	2025-11-04 18:51:00	00:15:00	2025-11-05 01:50:02.152725+07	2025-11-05 01:51:02.336835+07	2025-11-05 01:52:01.152725+07	f	\N	2025-11-07 21:37:20.719638+07
95550ac8-19ab-4ec7-b6b7-e22ffebc7b23	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:51:38.477145+07	2025-11-05 01:51:38.491631+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:51:38.477145+07	2025-11-05 01:51:38.525964+07	2025-11-05 01:59:38.477145+07	f	\N	2025-11-07 21:37:20.719638+07
0d781a2d-d3dd-4e2a-b8c5-d11b61c1ed91	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:52:21.400093+07	2025-11-05 01:52:21.414515+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:52:21.400093+07	2025-11-05 01:52:21.448553+07	2025-11-05 02:00:21.400093+07	f	\N	2025-11-07 21:37:20.719638+07
d4282ba4-1086-4089-b019-bebbbfcceb5c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:52:01.331206+07	2025-11-05 01:52:21.557478+07	\N	2025-11-04 18:52:00	00:15:00	2025-11-05 01:51:02.331206+07	2025-11-05 01:52:21.58071+07	2025-11-05 01:53:01.331206+07	f	\N	2025-11-07 21:37:20.719638+07
eb692c21-4373-4bc2-b6f3-10d676596f8c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:52:42.172575+07	2025-11-05 01:52:42.187081+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:52:42.172575+07	2025-11-05 01:52:42.229472+07	2025-11-05 02:00:42.172575+07	f	\N	2025-11-07 21:37:20.719638+07
8ac1328c-9713-4525-9f59-d3d7ed35ba0d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:54:01.476742+07	2025-11-05 01:54:03.904519+07	\N	2025-11-04 18:54:00	00:15:00	2025-11-05 01:53:02.476742+07	2025-11-05 01:54:03.927041+07	2025-11-05 01:55:01.476742+07	f	\N	2025-11-07 21:37:20.719638+07
cae568e9-8524-4792-8f07-b0170f5796fe	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:20:32.895419+07	2025-11-05 02:20:32.905908+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:20:32.895419+07	2025-11-05 02:20:32.935396+07	2025-11-05 02:28:32.895419+07	f	\N	2025-11-07 21:37:20.719638+07
611d4e77-025e-4f6b-b4ea-480016cf6d6e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:16:01.311707+07	2025-11-05 01:16:02.013865+07	\N	2025-11-04 18:16:00	00:15:00	2025-11-05 01:15:02.311707+07	2025-11-05 01:16:02.03672+07	2025-11-05 01:17:01.311707+07	f	\N	2025-11-07 21:37:20.719638+07
f6373c70-3bab-44d4-a190-696a03221280	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:27:50.799635+07	2025-11-05 01:27:50.807821+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:27:50.799635+07	2025-11-05 01:27:50.836471+07	2025-11-05 01:35:50.799635+07	f	\N	2025-11-07 21:37:20.719638+07
296766de-fa97-4889-b51f-e705610fd9d1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:16:24.252044+07	2025-11-05 01:16:24.260922+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:16:24.252044+07	2025-11-05 01:16:24.294734+07	2025-11-05 01:24:24.252044+07	f	\N	2025-11-07 21:37:20.719638+07
432831b4-c498-4ab3-8050-ed98b0f3901a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:28:01.623081+07	2025-11-05 01:28:02.959109+07	\N	2025-11-04 18:28:00	00:15:00	2025-11-05 01:27:03.623081+07	2025-11-05 01:28:02.980613+07	2025-11-05 01:29:01.623081+07	f	\N	2025-11-07 21:37:20.719638+07
08f92505-a98c-4a9c-b542-1de528d26736	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:16:30.846604+07	2025-11-05 01:16:30.856959+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:16:30.846604+07	2025-11-05 01:16:30.885513+07	2025-11-05 01:24:30.846604+07	f	\N	2025-11-07 21:37:20.719638+07
9b1a7964-97d7-41d8-899a-eb9eb82dacde	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:29:01.976105+07	2025-11-05 01:29:04.372608+07	\N	2025-11-04 18:29:00	00:15:00	2025-11-05 01:28:02.976105+07	2025-11-05 01:29:04.400326+07	2025-11-05 01:30:01.976105+07	f	\N	2025-11-07 21:37:20.719638+07
1a6cd814-0fba-4330-b2fd-8467721d0fd1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:16:37.59158+07	2025-11-05 01:16:37.658262+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:16:37.59158+07	2025-11-05 01:16:37.709377+07	2025-11-05 01:24:37.59158+07	f	\N	2025-11-07 21:37:20.719638+07
6e31bd8d-76c2-4acf-a9d1-e4a9ba60e07f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:30:01.397489+07	2025-11-05 01:30:04.488013+07	\N	2025-11-04 18:30:00	00:15:00	2025-11-05 01:29:04.397489+07	2025-11-05 01:30:04.531725+07	2025-11-05 01:31:01.397489+07	f	\N	2025-11-07 21:37:20.719638+07
ce489e5e-f193-4e90-937f-db87d59d3765	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:16:51.363273+07	2025-11-05 01:16:51.37316+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:16:51.363273+07	2025-11-05 01:16:51.40301+07	2025-11-05 01:24:51.363273+07	f	\N	2025-11-07 21:37:20.719638+07
21047d32-32cf-4476-9b90-1a2f3a9aae3e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:31:01.523417+07	2025-11-05 01:31:04.610524+07	\N	2025-11-04 18:31:00	00:15:00	2025-11-05 01:30:04.523417+07	2025-11-05 01:31:04.634341+07	2025-11-05 01:32:01.523417+07	f	\N	2025-11-07 21:37:20.719638+07
e6e54bb8-6742-4287-a475-53ab1c8d44f0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:17:01.033986+07	2025-11-05 01:17:03.520396+07	\N	2025-11-04 18:17:00	00:15:00	2025-11-05 01:16:02.033986+07	2025-11-05 01:17:03.540735+07	2025-11-05 01:18:01.033986+07	f	\N	2025-11-07 21:37:20.719638+07
c86e9915-8917-4180-85ff-3f1744569a99	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:32:01.626583+07	2025-11-05 01:32:03.33645+07	\N	2025-11-04 18:32:00	00:15:00	2025-11-05 01:31:04.626583+07	2025-11-05 01:32:03.355408+07	2025-11-05 01:33:01.626583+07	f	\N	2025-11-07 21:37:20.719638+07
9c9e3799-2ea6-4f92-86e8-b673ab1adcf8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:17:40.22456+07	2025-11-05 01:17:40.23385+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:17:40.22456+07	2025-11-05 01:17:40.2608+07	2025-11-05 01:25:40.22456+07	f	\N	2025-11-07 21:37:20.719638+07
0427c67e-39ac-46c7-a973-4d1b3fa548a5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:33:01.351862+07	2025-11-05 01:33:03.484677+07	\N	2025-11-04 18:33:00	00:15:00	2025-11-05 01:32:03.351862+07	2025-11-05 01:33:03.5011+07	2025-11-05 01:34:01.351862+07	f	\N	2025-11-07 21:37:20.719638+07
56e96206-0441-4dc2-900a-82624b4f216b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:17:53.887468+07	2025-11-05 01:17:53.898252+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:17:53.887468+07	2025-11-05 01:17:53.925999+07	2025-11-05 01:25:53.887468+07	f	\N	2025-11-07 21:37:20.719638+07
93bf9ac7-2387-430b-a66e-c3077d301e3f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:18:06.013518+07	2025-11-05 01:18:06.022013+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:18:06.013518+07	2025-11-05 01:18:06.046683+07	2025-11-05 01:26:06.013518+07	f	\N	2025-11-07 21:37:20.719638+07
9e4493a1-9f21-4c2a-a40c-b5108c78d875	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:36:01.71526+07	2025-11-05 01:36:03.859003+07	\N	2025-11-04 18:36:00	00:15:00	2025-11-05 01:35:03.71526+07	2025-11-05 01:36:03.867297+07	2025-11-05 01:37:01.71526+07	f	\N	2025-11-07 21:37:20.719638+07
16401285-8810-4918-9e8e-710cbdf281c5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:18:01.536373+07	2025-11-05 01:18:06.19275+07	\N	2025-11-04 18:18:00	00:15:00	2025-11-05 01:17:03.536373+07	2025-11-05 01:18:06.221202+07	2025-11-05 01:19:01.536373+07	f	\N	2025-11-07 21:37:20.719638+07
d5047505-a532-42e8-9f99-60194f4e0289	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:37:01.864787+07	2025-11-05 01:37:03.997572+07	\N	2025-11-04 18:37:00	00:15:00	2025-11-05 01:36:03.864787+07	2025-11-05 01:37:04.007351+07	2025-11-05 01:38:01.864787+07	f	\N	2025-11-07 21:37:20.719638+07
a67f9204-7c49-4045-9656-7e311b5220db	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:36:47.203999+07	2025-11-05 01:37:47.192621+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:34:47.203999+07	2025-11-05 01:37:47.202808+07	2025-11-05 01:44:47.203999+07	f	\N	2025-11-07 21:37:20.719638+07
a401daf7-8993-42f7-b799-97fb0b1b2b53	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:18:19.018042+07	2025-11-05 01:18:19.028661+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:18:19.018042+07	2025-11-05 01:18:19.055208+07	2025-11-05 01:26:19.018042+07	f	\N	2025-11-07 21:37:20.719638+07
befdfd68-811b-4e90-98b0-a91cd30d626c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:19:01.380765+07	2025-11-05 01:19:03.247305+07	\N	2025-11-04 18:19:00	00:15:00	2025-11-05 01:18:06.380765+07	2025-11-05 01:19:03.272854+07	2025-11-05 01:20:01.380765+07	f	\N	2025-11-07 21:37:20.719638+07
9d8372fd-8333-4621-a82b-eacccaa704b9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:39:01.138642+07	2025-11-05 01:39:04.237095+07	\N	2025-11-04 18:39:00	00:15:00	2025-11-05 01:38:04.138642+07	2025-11-05 01:39:04.248383+07	2025-11-05 01:40:01.138642+07	f	\N	2025-11-07 21:37:20.719638+07
c34a0d76-372e-4806-aa14-66dd1119f5dd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:19:58.432389+07	2025-11-05 01:19:58.447053+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:19:58.432389+07	2025-11-05 01:19:58.480621+07	2025-11-05 01:27:58.432389+07	f	\N	2025-11-07 21:37:20.719638+07
f7cde758-8706-40b1-883b-d154c0762e6b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:40:01.245389+07	2025-11-05 01:40:04.349942+07	\N	2025-11-04 18:40:00	00:15:00	2025-11-05 01:39:04.245389+07	2025-11-05 01:40:04.359303+07	2025-11-05 01:41:01.245389+07	f	\N	2025-11-07 21:37:20.719638+07
125c6f01-73c9-4a08-be14-6cc788dc282d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:20:01.267758+07	2025-11-05 01:20:02.595644+07	\N	2025-11-04 18:20:00	00:15:00	2025-11-05 01:19:03.267758+07	2025-11-05 01:20:02.616458+07	2025-11-05 01:21:01.267758+07	f	\N	2025-11-07 21:37:20.719638+07
3b5af1cd-ea83-403a-a631-030de17be795	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:41:01.357166+07	2025-11-05 01:41:04.478409+07	\N	2025-11-04 18:41:00	00:15:00	2025-11-05 01:40:04.357166+07	2025-11-05 01:41:04.489076+07	2025-11-05 01:42:01.357166+07	f	\N	2025-11-07 21:37:20.719638+07
0e65e357-69a8-48a8-97eb-2dede199bc4d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:20:21.177883+07	2025-11-05 01:20:21.18866+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:20:21.177883+07	2025-11-05 01:20:21.218647+07	2025-11-05 01:28:21.177883+07	f	\N	2025-11-07 21:37:20.719638+07
8a6f2444-f800-447d-806b-645a5cdd4a6d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:20:41.457344+07	2025-11-05 01:20:41.467661+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:20:41.457344+07	2025-11-05 01:20:41.498622+07	2025-11-05 01:28:41.457344+07	f	\N	2025-11-07 21:37:20.719638+07
f6ef79f5-a896-48ca-8531-84f91521c118	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:20:48.799143+07	2025-11-05 01:20:48.807566+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:20:48.799143+07	2025-11-05 01:20:48.834335+07	2025-11-05 01:28:48.799143+07	f	\N	2025-11-07 21:37:20.719638+07
1c2a9178-17fa-46e9-96bb-036d3453498a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:21:01.611326+07	2025-11-05 01:21:04.951057+07	\N	2025-11-04 18:21:00	00:15:00	2025-11-05 01:20:02.611326+07	2025-11-05 01:21:04.969093+07	2025-11-05 01:22:01.611326+07	f	\N	2025-11-07 21:37:20.719638+07
fa8ad73f-2151-49b0-b707-061bae8b9e16	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:22:01.96533+07	2025-11-05 01:22:05.049642+07	\N	2025-11-04 18:22:00	00:15:00	2025-11-05 01:21:04.96533+07	2025-11-05 01:22:05.062242+07	2025-11-05 01:23:01.96533+07	f	\N	2025-11-07 21:37:20.719638+07
f3381ae0-8c07-482d-882d-517fd8ab5e18	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:23:01.059547+07	2025-11-05 01:23:01.164237+07	\N	2025-11-04 18:23:00	00:15:00	2025-11-05 01:22:05.059547+07	2025-11-05 01:23:01.178319+07	2025-11-05 01:24:01.059547+07	f	\N	2025-11-07 21:37:20.719638+07
8f84b804-0ad5-468d-b612-f06f37c9ccf9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:23:56.898103+07	2025-11-05 01:23:56.916782+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:23:56.898103+07	2025-11-05 01:23:56.9507+07	2025-11-05 01:31:56.898103+07	f	\N	2025-11-07 21:37:20.719638+07
9f5d9eda-6a37-482d-acfd-8a6f54ad1729	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:24:05.436445+07	2025-11-05 01:24:05.452968+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:24:05.436445+07	2025-11-05 01:24:05.491097+07	2025-11-05 01:32:05.436445+07	f	\N	2025-11-07 21:37:20.719638+07
4c9f36b9-6ba3-411d-b577-3cb59da31ca3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:24:01.173505+07	2025-11-05 01:24:05.609795+07	\N	2025-11-04 18:24:00	00:15:00	2025-11-05 01:23:01.173505+07	2025-11-05 01:24:05.64832+07	2025-11-05 01:25:01.173505+07	f	\N	2025-11-07 21:37:20.719638+07
65da5a5d-21f4-4711-9072-ab1dc1434c2f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:24:23.140563+07	2025-11-05 01:24:23.155212+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:24:23.140563+07	2025-11-05 01:24:23.189986+07	2025-11-05 01:32:23.140563+07	f	\N	2025-11-07 21:37:20.719638+07
d9bbef4c-7291-4925-9f69-d84913985a36	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:25:01.828806+07	2025-11-05 01:25:03.403243+07	\N	2025-11-04 18:25:00	00:15:00	2025-11-05 01:24:05.828806+07	2025-11-05 01:25:03.41802+07	2025-11-05 01:26:01.828806+07	f	\N	2025-11-07 21:37:20.719638+07
9a1803ea-e37a-45de-95ed-8dc2d809f48d	xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762280668416-Tong hop NB.2021-2025.IN.xlsx", "userId": 5, "template": "excel2", "modelName": "cobia_xgboost", "originalname": "Tong hop NB.2021-2025.IN.xlsx"}	completed	3	0	60000	f	2025-11-05 01:24:28.425816+07	2025-11-05 01:24:29.512409+07	\N	\N	00:15:00	2025-11-05 01:24:28.425816+07	2025-11-05 01:25:57.24637+07	2025-11-19 01:24:28.425816+07	f	{"parsed": 32, "created": 32}	2025-11-07 21:37:20.719638+07
7614384e-4303-4e1e-a610-8422eb71fa37	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:26:01.416154+07	2025-11-05 01:26:03.507089+07	\N	2025-11-04 18:26:00	00:15:00	2025-11-05 01:25:03.416154+07	2025-11-05 01:26:03.521747+07	2025-11-05 01:27:01.416154+07	f	\N	2025-11-07 21:37:20.719638+07
a3bd1e99-59df-4f57-bb39-c313fcd22de2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:27:01.514368+07	2025-11-05 01:27:03.616508+07	\N	2025-11-04 18:27:00	00:15:00	2025-11-05 01:26:03.514368+07	2025-11-05 01:27:03.626354+07	2025-11-05 01:28:01.514368+07	f	\N	2025-11-07 21:37:20.719638+07
58f894fe-3e0b-4f24-9553-acd937095fab	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:26:23.195243+07	2025-11-05 01:27:23.172304+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:24:23.195243+07	2025-11-05 01:27:23.196466+07	2025-11-05 01:34:23.195243+07	f	\N	2025-11-07 21:37:20.719638+07
8c512b9b-0b33-4168-acce-64a034d3b217	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:53:01.683472+07	2025-11-05 01:53:02.453792+07	\N	2025-11-04 18:53:00	00:15:00	2025-11-05 01:52:21.683472+07	2025-11-05 01:53:02.483237+07	2025-11-05 01:54:01.683472+07	f	\N	2025-11-07 21:37:20.719638+07
d25c5e04-2a50-42ef-86fc-7160b0ca8ded	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:56:01.119064+07	2025-11-05 01:56:02.221193+07	\N	2025-11-04 18:56:00	00:15:00	2025-11-05 01:55:02.119064+07	2025-11-05 01:56:02.23453+07	2025-11-05 01:57:01.119064+07	f	\N	2025-11-07 21:37:20.719638+07
f80e96ea-f55b-4318-8dae-27f5dc7dbfff	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:54:03.749508+07	2025-11-05 01:54:03.764644+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:54:03.749508+07	2025-11-05 01:54:03.803285+07	2025-11-05 02:02:03.749508+07	f	\N	2025-11-07 21:37:20.719638+07
dd687bcd-af18-4f69-948d-6311eb7381f7	xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762282500514-Tong hop NB.2021-2025.IN.xlsx", "userId": 5, "template": "excel2", "modelName": "cobia_xgboost", "originalname": "Tong hop NB.2021-2025.IN.xlsx"}	completed	3	0	60000	f	2025-11-05 01:55:00.525943+07	2025-11-05 01:55:02.349421+07	\N	\N	00:15:00	2025-11-05 01:55:00.525943+07	2025-11-05 01:56:29.880875+07	2025-11-19 01:55:00.525943+07	f	{"parsed": 32, "created": 32}	2025-11-07 21:37:20.719638+07
f1e71f05-b5fc-4bee-93c8-9501e4e92742	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:57:14.521012+07	2025-11-05 01:57:14.530915+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:57:14.521012+07	2025-11-05 01:57:14.562932+07	2025-11-05 02:05:14.521012+07	f	\N	2025-11-07 21:37:20.719638+07
d27afa3d-96e6-4d99-8fe6-b935e7d06af1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:54:28.176371+07	2025-11-05 01:54:28.187365+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:54:28.176371+07	2025-11-05 01:54:28.215745+07	2025-11-05 02:02:28.176371+07	f	\N	2025-11-07 21:37:20.719638+07
d93a8937-0583-4129-911a-8fc05c0b098c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:58:01.364151+07	2025-11-05 01:58:02.76898+07	\N	2025-11-04 18:58:00	00:15:00	2025-11-05 01:57:02.364151+07	2025-11-05 01:58:02.794902+07	2025-11-05 01:59:01.364151+07	f	\N	2025-11-07 21:37:20.719638+07
4d00640e-9f10-43e4-86c1-8066b15ffdfa	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:54:45.876904+07	2025-11-05 01:54:45.890293+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:54:45.876904+07	2025-11-05 01:54:45.921046+07	2025-11-05 02:02:45.876904+07	f	\N	2025-11-07 21:37:20.719638+07
b1cc6be3-c285-4ab1-ae59-64f19e202833	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:58:16.891516+07	2025-11-05 01:58:16.91411+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:58:16.891516+07	2025-11-05 01:58:16.95405+07	2025-11-05 02:06:16.891516+07	f	\N	2025-11-07 21:37:20.719638+07
c437e73c-82fd-4d5b-b1bd-b640d2013e19	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:55:01.050397+07	2025-11-05 01:55:02.101557+07	\N	2025-11-04 18:55:00	00:15:00	2025-11-05 01:54:04.050397+07	2025-11-05 01:55:02.124002+07	2025-11-05 01:56:01.050397+07	f	\N	2025-11-07 21:37:20.719638+07
101c6aa8-a0f7-4563-af5b-1d7f24b1bb2d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:58:24.66921+07	2025-11-05 01:58:24.683586+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:58:24.66921+07	2025-11-05 01:58:24.714939+07	2025-11-05 02:06:24.66921+07	f	\N	2025-11-07 21:37:20.719638+07
da95e5ed-7686-4a28-a397-9ad5e8a86166	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 01:58:37.317561+07	2025-11-05 01:58:37.331257+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 01:58:37.317561+07	2025-11-05 01:58:37.36183+07	2025-11-05 02:06:37.317561+07	f	\N	2025-11-07 21:37:20.719638+07
5d8844c6-f5d1-4238-ad4e-ba8135ce9b11	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 01:59:01.79098+07	2025-11-05 01:59:05.510183+07	\N	2025-11-04 18:59:00	00:15:00	2025-11-05 01:58:02.79098+07	2025-11-05 01:59:05.528872+07	2025-11-05 02:00:01.79098+07	f	\N	2025-11-07 21:37:20.719638+07
68c9b58a-b17a-4145-9482-12aa35fac468	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:00:01.525781+07	2025-11-05 02:00:01.624659+07	\N	2025-11-04 19:00:00	00:15:00	2025-11-05 01:59:05.525781+07	2025-11-05 02:00:01.649498+07	2025-11-05 02:01:01.525781+07	f	\N	2025-11-07 21:37:20.719638+07
119e6243-5d89-41e1-9084-078a5bbb2695	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:00:28.428744+07	2025-11-05 02:00:28.448307+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:00:28.428744+07	2025-11-05 02:00:28.492001+07	2025-11-05 02:08:28.428744+07	f	\N	2025-11-07 21:37:20.719638+07
58e8ca2c-4acb-4270-9b8f-ab71f5be50bf	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:00:47.098403+07	2025-11-05 02:00:47.109095+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:00:47.098403+07	2025-11-05 02:00:47.143764+07	2025-11-05 02:08:47.098403+07	f	\N	2025-11-07 21:37:20.719638+07
44b114c8-e8e9-4065-b313-a3da75822645	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:00:56.062629+07	2025-11-05 02:00:56.072649+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:00:56.062629+07	2025-11-05 02:00:56.103375+07	2025-11-05 02:08:56.062629+07	f	\N	2025-11-07 21:37:20.719638+07
eca292c3-298b-4490-b929-8f5c26c25328	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:01:01.644863+07	2025-11-05 02:01:04.217531+07	\N	2025-11-04 19:01:00	00:15:00	2025-11-05 02:00:01.644863+07	2025-11-05 02:01:04.285774+07	2025-11-05 02:02:01.644863+07	f	\N	2025-11-07 21:37:20.719638+07
aa01d7d0-0dcd-4b1d-80b1-82a6be9846f6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:02:01.264637+07	2025-11-05 02:02:04.332568+07	\N	2025-11-04 19:02:00	00:15:00	2025-11-05 02:01:04.264637+07	2025-11-05 02:02:04.359977+07	2025-11-05 02:03:01.264637+07	f	\N	2025-11-07 21:37:20.719638+07
0c9d867b-2967-460f-bd06-64c56a96b053	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:02:51.236+07	2025-11-05 02:02:51.251714+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:02:51.236+07	2025-11-05 02:02:51.289713+07	2025-11-05 02:10:51.236+07	f	\N	2025-11-07 21:37:20.719638+07
5c43d086-6a8f-4588-8326-095107269577	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:03:01.353709+07	2025-11-05 02:03:03.4441+07	\N	2025-11-04 19:03:00	00:15:00	2025-11-05 02:02:04.353709+07	2025-11-05 02:03:03.462997+07	2025-11-05 02:04:01.353709+07	f	\N	2025-11-07 21:37:20.719638+07
6cac48a5-42a8-4319-8c19-bf5577d19f5f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:03:19.474997+07	2025-11-05 02:03:19.484168+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:03:19.474997+07	2025-11-05 02:03:19.511888+07	2025-11-05 02:11:19.474997+07	f	\N	2025-11-07 21:37:20.719638+07
0664ddd6-458b-47ac-aea0-8d72b249f112	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:03:41.085655+07	2025-11-05 02:03:41.103665+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:03:41.085655+07	2025-11-05 02:03:41.14333+07	2025-11-05 02:11:41.085655+07	f	\N	2025-11-07 21:37:20.719638+07
1216a55a-4b74-4f89-b506-8d86598310e5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:04:01.459116+07	2025-11-05 02:04:05.276986+07	\N	2025-11-04 19:04:00	00:15:00	2025-11-05 02:03:03.459116+07	2025-11-05 02:04:05.307864+07	2025-11-05 02:05:01.459116+07	f	\N	2025-11-07 21:37:20.719638+07
ea518051-f2af-4f90-b229-5ab98cd9301c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:05:01.304989+07	2025-11-05 02:05:01.387988+07	\N	2025-11-04 19:05:00	00:15:00	2025-11-05 02:04:05.304989+07	2025-11-05 02:05:01.399916+07	2025-11-05 02:06:01.304989+07	f	\N	2025-11-07 21:37:20.719638+07
319e729d-4ded-4775-bcd0-941e70678fb1	xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762283025169-Tong hop NB.2021-2025.IN.xlsx", "userId": 5, "template": "excel2", "modelName": "cobia_xgboost", "originalname": "Tong hop NB.2021-2025.IN.xlsx"}	completed	3	0	60000	f	2025-11-05 02:03:45.206065+07	2025-11-05 02:03:45.480604+07	\N	\N	00:15:00	2025-11-05 02:03:45.206065+07	2025-11-05 02:05:13.136653+07	2025-11-19 02:03:45.206065+07	f	{"parsed": 32, "created": 32}	2025-11-07 21:37:20.719638+07
6e986a5c-9eb8-4252-b712-2a700280773d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:06:01.396246+07	2025-11-05 02:06:01.519475+07	\N	2025-11-04 19:06:00	00:15:00	2025-11-05 02:05:01.396246+07	2025-11-05 02:06:01.542487+07	2025-11-05 02:07:01.396246+07	f	\N	2025-11-07 21:37:20.719638+07
fac9b273-4661-46f9-aa4f-a679b6f33f00	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:05:41.150396+07	2025-11-05 02:06:41.127393+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:03:41.150396+07	2025-11-05 02:06:41.147646+07	2025-11-05 02:13:41.150396+07	f	\N	2025-11-07 21:37:20.719638+07
8c0d4f08-5c97-4a78-b22f-32878443f176	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:07:01.536485+07	2025-11-05 02:07:01.618786+07	\N	2025-11-04 19:07:00	00:15:00	2025-11-05 02:06:01.536485+07	2025-11-05 02:07:01.629714+07	2025-11-05 02:08:01.536485+07	f	\N	2025-11-07 21:37:20.719638+07
b3b3eac4-7055-4e15-a5a9-2e6c616fe619	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:08:01.627053+07	2025-11-05 02:08:01.722043+07	\N	2025-11-04 19:08:00	00:15:00	2025-11-05 02:07:01.627053+07	2025-11-05 02:08:01.748127+07	2025-11-05 02:09:01.627053+07	f	\N	2025-11-07 21:37:20.719638+07
28c516ab-8c4c-413e-b695-817ec0a55532	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:09:01.742583+07	2025-11-05 02:09:01.837121+07	\N	2025-11-04 19:09:00	00:15:00	2025-11-05 02:08:01.742583+07	2025-11-05 02:09:01.853966+07	2025-11-05 02:10:01.742583+07	f	\N	2025-11-07 21:37:20.719638+07
d5bc7c9c-f756-40f2-9a98-b020846a1dd0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:08:41.151291+07	2025-11-05 02:09:41.146625+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:06:41.151291+07	2025-11-05 02:09:41.175642+07	2025-11-05 02:16:41.151291+07	f	\N	2025-11-07 21:37:20.719638+07
091e98a3-f82e-460f-acf9-19d25ca590f9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:10:01.848181+07	2025-11-05 02:10:01.928822+07	\N	2025-11-04 19:10:00	00:15:00	2025-11-05 02:09:01.848181+07	2025-11-05 02:10:01.939535+07	2025-11-05 02:11:01.848181+07	f	\N	2025-11-07 21:37:20.719638+07
b8cf3fc5-4790-483f-ad73-8260a741f97e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:11:01.937766+07	2025-11-05 02:11:02.04216+07	\N	2025-11-04 19:11:00	00:15:00	2025-11-05 02:10:01.937766+07	2025-11-05 02:11:02.051318+07	2025-11-05 02:12:01.937766+07	f	\N	2025-11-07 21:37:20.719638+07
b20f0aa8-2ee1-4243-b2dd-1ec7c727ccbe	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:12:01.049363+07	2025-11-05 02:12:02.178833+07	\N	2025-11-04 19:12:00	00:15:00	2025-11-05 02:11:02.049363+07	2025-11-05 02:12:02.193379+07	2025-11-05 02:13:01.049363+07	f	\N	2025-11-07 21:37:20.719638+07
a1a49346-0892-4544-b902-b51ab05ec88b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:12:30.109095+07	2025-11-05 02:12:30.122513+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:12:30.109095+07	2025-11-05 02:12:30.157834+07	2025-11-05 02:20:30.109095+07	f	\N	2025-11-07 21:37:20.719638+07
47578423-d29e-49d6-80f9-8b2dadbe0bc5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:12:41.905442+07	2025-11-05 02:12:41.913542+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:12:41.905442+07	2025-11-05 02:12:41.943072+07	2025-11-05 02:20:41.905442+07	f	\N	2025-11-07 21:37:20.719638+07
20257efd-0066-457d-abc2-41608ae8a19d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:13:01.190117+07	2025-11-05 02:13:02.077313+07	\N	2025-11-04 19:13:00	00:15:00	2025-11-05 02:12:02.190117+07	2025-11-05 02:13:02.094485+07	2025-11-05 02:14:01.190117+07	f	\N	2025-11-07 21:37:20.719638+07
a422016a-2f0f-40aa-8c12-dd41923318ac	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:14:01.090657+07	2025-11-05 02:14:02.200075+07	\N	2025-11-04 19:14:00	00:15:00	2025-11-05 02:13:02.090657+07	2025-11-05 02:14:02.212706+07	2025-11-05 02:15:01.090657+07	f	\N	2025-11-07 21:37:20.719638+07
6e10ee19-1e9c-49ea-af45-1966ac20ac69	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:14:08.264896+07	2025-11-05 02:14:08.274982+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:14:08.264896+07	2025-11-05 02:14:08.307515+07	2025-11-05 02:22:08.264896+07	f	\N	2025-11-07 21:37:20.719638+07
8f3ca854-53e8-4e0d-af95-a59c2fd55c6c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:34:38.639301+07	2025-11-05 02:34:38.659004+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:34:38.639301+07	2025-11-05 02:34:38.688131+07	2025-11-05 02:42:38.639301+07	f	\N	2025-11-07 21:37:20.719638+07
a37a9cb9-df8b-4652-91be-eefb8aa14a25	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:20:50.199664+07	2025-11-05 02:20:50.212432+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:20:50.199664+07	2025-11-05 02:20:50.24939+07	2025-11-05 02:28:50.199664+07	f	\N	2025-11-07 21:37:20.719638+07
256caa35-50b5-4477-b76a-25190e1207d8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:15:01.210255+07	2025-11-05 02:15:05.207441+07	\N	2025-11-04 19:15:00	00:15:00	2025-11-05 02:14:02.210255+07	2025-11-05 02:15:05.362457+07	2025-11-05 02:16:01.210255+07	f	\N	2025-11-07 21:37:20.719638+07
52d9acfa-5048-470c-a849-a08e6bf4c208	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:21:01.503298+07	2025-11-05 02:21:02.3945+07	\N	2025-11-04 19:21:00	00:15:00	2025-11-05 02:20:02.503298+07	2025-11-05 02:21:02.43168+07	2025-11-05 02:22:01.503298+07	f	\N	2025-11-07 21:37:20.719638+07
c2556be0-8fc9-48ee-92ce-3aff81aa2985	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:34:52.377211+07	2025-11-05 02:34:52.390009+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:34:52.377211+07	2025-11-05 02:34:52.419982+07	2025-11-05 02:42:52.377211+07	f	\N	2025-11-07 21:37:20.719638+07
bd2fb1ec-5cd8-4377-a904-04e709295aef	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:22:56.050695+07	2025-11-05 02:22:56.059658+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:22:56.050695+07	2025-11-05 02:22:56.085839+07	2025-11-05 02:30:56.050695+07	f	\N	2025-11-07 21:37:20.719638+07
1303400a-d2cf-4f2d-9502-9489f3ea1c8b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:35:04.282658+07	2025-11-05 02:35:04.294417+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:35:04.282658+07	2025-11-05 02:35:04.32322+07	2025-11-05 02:43:04.282658+07	f	\N	2025-11-07 21:37:20.719638+07
ddff4f38-5c18-47bb-9759-6907d7635fb2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:23:27.122964+07	2025-11-05 02:23:27.132725+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:23:27.122964+07	2025-11-05 02:23:27.164358+07	2025-11-05 02:31:27.122964+07	f	\N	2025-11-07 21:37:20.719638+07
a1dde05c-be0a-4348-a3cd-5340c79b5e8e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:35:01.131723+07	2025-11-05 02:35:04.44371+07	\N	2025-11-04 19:35:00	00:15:00	2025-11-05 02:34:05.131723+07	2025-11-05 02:35:04.46776+07	2025-11-05 02:36:01.131723+07	f	\N	2025-11-07 21:37:20.719638+07
46819f23-3798-487c-912b-0931bf0bfa66	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:24:22.177513+07	2025-11-05 02:24:22.208639+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:24:22.177513+07	2025-11-05 02:24:22.423131+07	2025-11-05 02:32:22.177513+07	f	\N	2025-11-07 21:37:20.719638+07
ba9c3c2d-d4b1-459c-971c-4b75c6f32ed6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:35:10.227198+07	2025-11-05 02:35:10.237975+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:35:10.227198+07	2025-11-05 02:35:10.26749+07	2025-11-05 02:43:10.227198+07	f	\N	2025-11-07 21:37:20.719638+07
6e0a9dd8-b18f-496b-aa18-3469cd020266	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:24:52.180993+07	2025-11-05 02:24:52.196649+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:24:52.180993+07	2025-11-05 02:24:52.272094+07	2025-11-05 02:32:52.180993+07	f	\N	2025-11-07 21:37:20.719638+07
eec4da1c-9e43-44f7-bdce-6b135991f057	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:25:01.886816+07	2025-11-05 02:25:04.462501+07	\N	2025-11-04 19:25:00	00:15:00	2025-11-05 02:24:02.886816+07	2025-11-05 02:25:04.481401+07	2025-11-05 02:26:01.886816+07	f	\N	2025-11-07 21:37:20.719638+07
35681cbc-0e2d-4800-aabf-391b756f3df8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:35:16.547083+07	2025-11-05 02:35:16.557824+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:35:16.547083+07	2025-11-05 02:35:16.588406+07	2025-11-05 02:43:16.547083+07	f	\N	2025-11-07 21:37:20.719638+07
e322433f-b518-49b3-a3ed-2dbcba965cb0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:27:01.694852+07	2025-11-05 02:27:01.932703+07	\N	2025-11-04 19:27:00	00:15:00	2025-11-05 02:26:04.694852+07	2025-11-05 02:27:01.954432+07	2025-11-05 02:28:01.694852+07	f	\N	2025-11-07 21:37:20.719638+07
65affe5f-4141-46c2-8be9-464eab265c46	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:35:26.537004+07	2025-11-05 02:35:26.553878+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:35:26.537004+07	2025-11-05 02:35:26.582444+07	2025-11-05 02:43:26.537004+07	f	\N	2025-11-07 21:37:20.719638+07
f0ba9824-dba8-41f1-9f2d-c3eec3d9a979	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:27:26.382201+07	2025-11-05 02:27:26.391379+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:27:26.382201+07	2025-11-05 02:27:26.417356+07	2025-11-05 02:35:26.382201+07	f	\N	2025-11-07 21:37:20.719638+07
05acf81f-66ef-4c1b-91c8-540030991898	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:27:51.170362+07	2025-11-05 02:27:51.191367+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:27:51.170362+07	2025-11-05 02:27:51.240065+07	2025-11-05 02:35:51.170362+07	f	\N	2025-11-07 21:37:20.719638+07
c7a16e7a-ea28-4d79-8018-56d0a7b78f2f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:35:32.827475+07	2025-11-05 02:35:32.846107+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:35:32.827475+07	2025-11-05 02:35:32.880427+07	2025-11-05 02:43:32.827475+07	f	\N	2025-11-07 21:37:20.719638+07
3cc875d4-424e-4bf5-ae32-cc802eddf753	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:28:01.950403+07	2025-11-05 02:28:05.808154+07	\N	2025-11-04 19:28:00	00:15:00	2025-11-05 02:27:01.950403+07	2025-11-05 02:28:05.830289+07	2025-11-05 02:29:01.950403+07	f	\N	2025-11-07 21:37:20.719638+07
07c94833-40f1-4b2c-b21a-621ac32d6475	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:35:39.178399+07	2025-11-05 02:35:39.187501+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:35:39.178399+07	2025-11-05 02:35:39.214701+07	2025-11-05 02:43:39.178399+07	f	\N	2025-11-07 21:37:20.719638+07
75f83258-48e7-4018-841d-3015e0e7e495	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:28:11.402288+07	2025-11-05 02:28:11.413144+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:28:11.402288+07	2025-11-05 02:28:11.442598+07	2025-11-05 02:36:11.402288+07	f	\N	2025-11-07 21:37:20.719638+07
37f57ec7-1c7a-4cb0-b2b9-2356067b9d40	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:28:31.724191+07	2025-11-05 02:28:31.736898+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:28:31.724191+07	2025-11-05 02:28:31.769214+07	2025-11-05 02:36:31.724191+07	f	\N	2025-11-07 21:37:20.719638+07
3edf4ebf-8bca-4d1a-ac47-0b4c14c03b0d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:31:09.877487+07	2025-11-05 02:31:09.893987+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:31:09.877487+07	2025-11-05 02:31:09.932324+07	2025-11-05 02:39:09.877487+07	f	\N	2025-11-07 21:37:20.719638+07
cf0d0151-c5a5-4c62-bade-fe64e1761cfa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:31:10.347307+07	2025-11-05 02:31:14.152171+07	\N	2025-11-04 19:31:00	00:15:00	2025-11-05 02:31:10.347307+07	2025-11-05 02:31:14.167599+07	2025-11-05 02:32:10.347307+07	f	\N	2025-11-07 21:37:20.719638+07
e52808c7-8d90-425d-b546-796fb40180e2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:32:08.635591+07	2025-11-05 02:32:08.654923+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:32:08.635591+07	2025-11-05 02:32:08.691746+07	2025-11-05 02:40:08.635591+07	f	\N	2025-11-07 21:37:20.719638+07
2d498e5a-bbbd-41b7-b1bb-cd1cb105cdbf	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:32:13.786254+07	2025-11-05 02:32:13.797284+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:32:13.786254+07	2025-11-05 02:32:13.825837+07	2025-11-05 02:40:13.786254+07	f	\N	2025-11-07 21:37:20.719638+07
7e3bdb11-00b7-483e-8610-379862e38d38	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:32:01.164608+07	2025-11-05 02:32:13.940035+07	\N	2025-11-04 19:32:00	00:15:00	2025-11-05 02:31:14.164608+07	2025-11-05 02:32:13.961883+07	2025-11-05 02:33:01.164608+07	f	\N	2025-11-07 21:37:20.719638+07
92b0977e-7a15-4b57-834d-9797f8a715c2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:32:22.295642+07	2025-11-05 02:32:22.30619+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:32:22.295642+07	2025-11-05 02:32:22.348941+07	2025-11-05 02:40:22.295642+07	f	\N	2025-11-07 21:37:20.719638+07
4a0e2e9b-d726-4190-b249-862a45d81277	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:32:31.716455+07	2025-11-05 02:32:31.728764+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:32:31.716455+07	2025-11-05 02:32:31.75649+07	2025-11-05 02:40:31.716455+07	f	\N	2025-11-07 21:37:20.719638+07
6295f84a-5d70-43f7-8507-7c42770ddf7d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:32:39.368237+07	2025-11-05 02:32:39.4043+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:32:39.368237+07	2025-11-05 02:32:39.586817+07	2025-11-05 02:40:39.368237+07	f	\N	2025-11-07 21:37:20.719638+07
27883e8a-7b59-46b1-ad42-23b4fe84a16f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:32:50.652697+07	2025-11-05 02:32:50.666858+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:32:50.652697+07	2025-11-05 02:32:50.704936+07	2025-11-05 02:40:50.652697+07	f	\N	2025-11-07 21:37:20.719638+07
66ae1369-34c3-419a-af4f-f72379b3c126	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:33:00.358052+07	2025-11-05 02:33:00.372122+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:33:00.358052+07	2025-11-05 02:33:00.405453+07	2025-11-05 02:41:00.358052+07	f	\N	2025-11-07 21:37:20.719638+07
1a9af222-660d-4111-8c87-5e5208e46448	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:33:07.019848+07	2025-11-05 02:33:07.02914+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:33:07.019848+07	2025-11-05 02:33:07.056203+07	2025-11-05 02:41:07.019848+07	f	\N	2025-11-07 21:37:20.719638+07
4888de89-38fd-470a-86b8-71a5b8993619	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:33:01.879548+07	2025-11-05 02:33:07.16022+07	\N	2025-11-04 19:33:00	00:15:00	2025-11-05 02:32:22.879548+07	2025-11-05 02:33:07.184633+07	2025-11-05 02:34:01.879548+07	f	\N	2025-11-07 21:37:20.719638+07
b9417b63-617f-431d-a1dc-45d12a76fcad	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:33:34.410403+07	2025-11-05 02:33:34.432269+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:33:34.410403+07	2025-11-05 02:33:34.498426+07	2025-11-05 02:41:34.410403+07	f	\N	2025-11-07 21:37:20.719638+07
fb77b958-5c94-4fc0-85bb-389971428895	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:33:48.872342+07	2025-11-05 02:33:48.880963+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:33:48.872342+07	2025-11-05 02:33:48.908883+07	2025-11-05 02:41:48.872342+07	f	\N	2025-11-07 21:37:20.719638+07
c6da53af-a016-4af9-ade4-878492e63505	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:34:01.799657+07	2025-11-05 02:34:05.117801+07	\N	2025-11-04 19:34:00	00:15:00	2025-11-05 02:33:00.799657+07	2025-11-05 02:34:05.1357+07	2025-11-05 02:35:01.799657+07	f	\N	2025-11-07 21:37:20.719638+07
767505eb-b15a-4a59-9388-db524df4b664	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:34:20.869246+07	2025-11-05 02:34:20.880326+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:34:20.869246+07	2025-11-05 02:34:20.916779+07	2025-11-05 02:42:20.869246+07	f	\N	2025-11-07 21:37:20.719638+07
5ffa56d7-8ee7-44cb-bed7-5a2ccc9af959	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:34:27.246894+07	2025-11-05 02:34:27.259327+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:34:27.246894+07	2025-11-05 02:34:27.28979+07	2025-11-05 02:42:27.246894+07	f	\N	2025-11-07 21:37:20.719638+07
39660986-3db7-4396-bbf5-20b798508f43	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:14:50.652615+07	2025-11-05 02:14:50.666353+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:14:50.652615+07	2025-11-05 02:14:50.702731+07	2025-11-05 02:22:50.652615+07	f	\N	2025-11-07 21:37:20.719638+07
b70d4452-cc7e-487a-81aa-9501048495ad	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:20:01.553532+07	2025-11-05 02:20:02.486371+07	\N	2025-11-04 19:20:00	00:15:00	2025-11-05 02:19:10.553532+07	2025-11-05 02:20:02.50872+07	2025-11-05 02:21:01.553532+07	f	\N	2025-11-07 21:37:20.719638+07
9d4c24cc-c005-44a5-ad1d-8669674cb149	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:14:57.045093+07	2025-11-05 02:14:57.055667+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:14:57.045093+07	2025-11-05 02:14:57.084118+07	2025-11-05 02:22:57.045093+07	f	\N	2025-11-07 21:37:20.719638+07
f4be8f02-8c98-4b8f-a4ea-dc6a563effc2	xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762284050786-Tong hop NB.2021-2025.IN.xlsx", "userId": 5, "template": "excel2", "modelName": "cobia_xgboost", "originalname": "Tong hop NB.2021-2025.IN.xlsx"}	failed	0	0	0	f	2025-11-05 02:20:50.799572+07	2025-11-05 02:20:52.617515+07	\N	\N	00:15:00	2025-11-05 02:20:50.799572+07	2025-11-05 02:20:56.452136+07	2025-11-19 02:20:50.799572+07	f	{"data": {"error": "Failed at row 1/32 (area: Luồng vào cảng Cái Lân tại cầu Bãi Cháy): getaddrinfo ENOTFOUND flask_backend"}, "name": "Error", "stack": "Error: Failed at row 1/32 (area: Luồng vào cảng Cái Lân tại cầu Bãi Cháy): getaddrinfo ENOTFOUND flask_backend\\n    at Object.json (D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\src\\\\workers\\\\importBoss.js:37:35)\\n    at exports.createBatchPredictionFromExcel2 (D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\src\\\\controllers\\\\predictionController.js:824:28)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)", "message": "Failed at row 1/32 (area: Luồng vào cảng Cái Lân tại cầu Bãi Cháy): getaddrinfo ENOTFOUND flask_backend", "statusCode": 500}	2025-11-07 21:37:20.719638+07
3aa952b2-6ecc-477f-8fe8-bf7cde5a94e9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:15:21.41192+07	2025-11-05 02:15:21.574698+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:15:21.41192+07	2025-11-05 02:15:22.004797+07	2025-11-05 02:23:21.41192+07	f	\N	2025-11-07 21:37:20.719638+07
c80b144f-a088-445e-bd70-98604959c7c7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:22:01.414967+07	2025-11-05 02:22:02.503861+07	\N	2025-11-04 19:22:00	00:15:00	2025-11-05 02:21:02.414967+07	2025-11-05 02:22:02.530258+07	2025-11-05 02:23:01.414967+07	f	\N	2025-11-07 21:37:20.719638+07
8ff0286a-b3c0-479b-a460-fd081c7cca4d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:22:48.643204+07	2025-11-05 02:22:48.655596+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:22:48.643204+07	2025-11-05 02:22:48.690379+07	2025-11-05 02:30:48.643204+07	f	\N	2025-11-07 21:37:20.719638+07
3dfdcf50-bd68-4061-9514-f09f551140a8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:16:01.356379+07	2025-11-05 02:16:02.040131+07	\N	2025-11-04 19:16:00	00:15:00	2025-11-05 02:15:05.356379+07	2025-11-05 02:16:02.058213+07	2025-11-05 02:17:01.356379+07	f	\N	2025-11-07 21:37:20.719638+07
d9fb30eb-046e-44eb-8729-671d3ab2c1d5	xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762283726736-Tong hop NB.2021-2025.IN.xlsx", "userId": 5, "template": "excel2", "modelName": "cobia_xgboost", "originalname": "Tong hop NB.2021-2025.IN.xlsx"}	completed	3	0	60000	f	2025-11-05 02:15:26.753868+07	2025-11-05 02:15:28.221298+07	\N	\N	00:15:00	2025-11-05 02:15:26.753868+07	2025-11-05 02:16:56.56287+07	2025-11-19 02:15:26.753868+07	f	{"parsed": 32, "created": 32}	2025-11-07 21:37:20.719638+07
0dbb6efb-062c-4c9c-af9c-60ad9e018f10	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:17:01.054061+07	2025-11-05 02:17:02.161652+07	\N	2025-11-04 19:17:00	00:15:00	2025-11-05 02:16:02.054061+07	2025-11-05 02:17:02.175377+07	2025-11-05 02:18:01.054061+07	f	\N	2025-11-07 21:37:20.719638+07
3261f50d-dc5f-4ac9-96a5-e9feb3d080a6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:23:01.525562+07	2025-11-05 02:23:04.192457+07	\N	2025-11-04 19:23:00	00:15:00	2025-11-05 02:22:02.525562+07	2025-11-05 02:23:04.383528+07	2025-11-05 02:24:01.525562+07	f	\N	2025-11-07 21:37:20.719638+07
1f7b75c6-8ef1-4f7b-a368-000d4b05de19	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:18:01.173214+07	2025-11-05 02:18:02.282013+07	\N	2025-11-04 19:18:00	00:15:00	2025-11-05 02:17:02.173214+07	2025-11-05 02:18:02.292652+07	2025-11-05 02:19:01.173214+07	f	\N	2025-11-07 21:37:20.719638+07
0ad3569c-9b55-450c-ae70-0ff2729d62eb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:17:22.013467+07	2025-11-05 02:18:21.580003+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:15:22.013467+07	2025-11-05 02:18:21.609706+07	2025-11-05 02:25:22.013467+07	f	\N	2025-11-07 21:37:20.719638+07
58cd7b83-0cd4-430d-aa16-07441bfa8a59	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:23:38.475289+07	2025-11-05 02:23:38.488509+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:23:38.475289+07	2025-11-05 02:23:38.530159+07	2025-11-05 02:31:38.475289+07	f	\N	2025-11-07 21:37:20.719638+07
eec11cc9-29d7-47d8-a821-4d2c98673ab8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:18:37.710423+07	2025-11-05 02:18:37.721093+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:18:37.710423+07	2025-11-05 02:18:37.749826+07	2025-11-05 02:26:37.710423+07	f	\N	2025-11-07 21:37:20.719638+07
85ea7c5c-6c32-479f-a664-83adb34ee8ba	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:24:01.320886+07	2025-11-05 02:24:02.793084+07	\N	2025-11-04 19:24:00	00:15:00	2025-11-05 02:23:04.320886+07	2025-11-05 02:24:02.908608+07	2025-11-05 02:25:01.320886+07	f	\N	2025-11-07 21:37:20.719638+07
090246da-0187-44a6-886c-0c993baa6c0d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:18:49.308274+07	2025-11-05 02:18:49.317665+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:18:49.308274+07	2025-11-05 02:18:49.342215+07	2025-11-05 02:26:49.308274+07	f	\N	2025-11-07 21:37:20.719638+07
ff26f539-0636-44a3-b1aa-6f3bfe093338	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:24:12.966912+07	2025-11-05 02:24:12.975935+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:24:12.966912+07	2025-11-05 02:24:13.009927+07	2025-11-05 02:32:12.966912+07	f	\N	2025-11-07 21:37:20.719638+07
49f6ea18-8dfb-4442-bda6-f9d2de688428	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:19:10.22361+07	2025-11-05 02:19:10.239902+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:19:10.22361+07	2025-11-05 02:19:10.277235+07	2025-11-05 02:27:10.22361+07	f	\N	2025-11-07 21:37:20.719638+07
a7c2b3c6-a5f9-4585-b71c-a7059a0dc07c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:19:01.289871+07	2025-11-05 02:19:10.390115+07	\N	2025-11-04 19:19:00	00:15:00	2025-11-05 02:18:02.289871+07	2025-11-05 02:19:10.416793+07	2025-11-05 02:20:01.289871+07	f	\N	2025-11-07 21:37:20.719638+07
e600a3fc-1342-4040-b5e0-fa4cab7d47be	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:24:33.545496+07	2025-11-05 02:24:33.556831+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:24:33.545496+07	2025-11-05 02:24:33.589354+07	2025-11-05 02:32:33.545496+07	f	\N	2025-11-07 21:37:20.719638+07
f93cc310-2f7f-4784-977c-b07a9a7391e0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:26:01.477399+07	2025-11-05 02:26:04.659079+07	\N	2025-11-04 19:26:00	00:15:00	2025-11-05 02:25:04.477399+07	2025-11-05 02:26:04.701317+07	2025-11-05 02:27:01.477399+07	f	\N	2025-11-07 21:37:20.719638+07
a7a59a10-c256-4bef-8136-80147849161f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:26:53.763328+07	2025-11-05 02:26:53.777399+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:26:53.763328+07	2025-11-05 02:26:53.812123+07	2025-11-05 02:34:53.763328+07	f	\N	2025-11-07 21:37:20.719638+07
321d351d-88b8-4346-ac7d-de18111e8455	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:27:18.27719+07	2025-11-05 02:27:18.288786+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:27:18.27719+07	2025-11-05 02:27:18.319234+07	2025-11-05 02:35:18.27719+07	f	\N	2025-11-07 21:37:20.719638+07
a8df2541-0aec-4822-82d6-6c06f4b8419c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:27:37.920089+07	2025-11-05 02:27:37.933746+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:27:37.920089+07	2025-11-05 02:27:37.967443+07	2025-11-05 02:35:37.920089+07	f	\N	2025-11-07 21:37:20.719638+07
e61882fa-9229-43a0-bb9e-ee1055b1f13a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:27:59.746786+07	2025-11-05 02:27:59.756271+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:27:59.746786+07	2025-11-05 02:27:59.783638+07	2025-11-05 02:35:59.746786+07	f	\N	2025-11-07 21:37:20.719638+07
d9852e80-ee02-4823-a2ca-ec9242d4c6a4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:28:05.647191+07	2025-11-05 02:28:05.658738+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:28:05.647191+07	2025-11-05 02:28:05.687066+07	2025-11-05 02:36:05.647191+07	f	\N	2025-11-07 21:37:20.719638+07
5962ad50-6425-4f69-9b55-620e5bea3f69	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:28:16.021485+07	2025-11-05 02:28:16.036775+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:28:16.021485+07	2025-11-05 02:28:16.071062+07	2025-11-05 02:36:16.021485+07	f	\N	2025-11-07 21:37:20.719638+07
f299ee54-3ffb-4f6e-9a2f-4689a6f71a24	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:28:42.869533+07	2025-11-05 02:28:42.893064+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:28:42.869533+07	2025-11-05 02:28:42.942036+07	2025-11-05 02:36:42.869533+07	f	\N	2025-11-07 21:37:20.719638+07
dbb0f1e5-586e-47e8-a71d-d0aaf8b53a94	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:35:46.638847+07	2025-11-05 02:35:46.650608+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:35:46.638847+07	2025-11-05 02:35:46.696671+07	2025-11-05 02:43:46.638847+07	f	\N	2025-11-07 21:37:20.719638+07
fe9d489c-e271-468a-9c0c-6a434877cc34	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:35:54.597783+07	2025-11-05 02:35:54.606608+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:35:54.597783+07	2025-11-05 02:35:54.635433+07	2025-11-05 02:43:54.597783+07	f	\N	2025-11-07 21:37:20.719638+07
2b7267f7-8424-40a3-84e6-bf9e909d61dd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:36:01.273582+07	2025-11-05 02:36:01.285431+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:36:01.273582+07	2025-11-05 02:36:01.314772+07	2025-11-05 02:44:01.273582+07	f	\N	2025-11-07 21:37:20.719638+07
dc735c69-8e47-4350-aad9-c577420b27f0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:36:01.593478+07	2025-11-05 02:36:05.433627+07	\N	2025-11-04 19:36:00	00:15:00	2025-11-05 02:35:04.593478+07	2025-11-05 02:36:05.451565+07	2025-11-05 02:37:01.593478+07	f	\N	2025-11-07 21:37:20.719638+07
ea08dc1f-c9d5-42d6-929b-2cdf03a706f7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:36:22.960219+07	2025-11-05 02:36:22.969977+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:36:22.960219+07	2025-11-05 02:36:22.997524+07	2025-11-05 02:44:22.960219+07	f	\N	2025-11-07 21:37:20.719638+07
0c34b948-2e9e-4a18-8282-2a4c3263e28f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:36:29.633149+07	2025-11-05 02:36:29.64196+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:36:29.633149+07	2025-11-05 02:36:29.671757+07	2025-11-05 02:44:29.633149+07	f	\N	2025-11-07 21:37:20.719638+07
e4116f1e-bfd6-4f72-963f-24f491118e4b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:36:37.098708+07	2025-11-05 02:36:37.121076+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:36:37.098708+07	2025-11-05 02:36:37.148076+07	2025-11-05 02:44:37.098708+07	f	\N	2025-11-07 21:37:20.719638+07
1fc48df2-f698-4f50-a6f8-106531c6749f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:36:46.798806+07	2025-11-05 02:36:46.808732+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:36:46.798806+07	2025-11-05 02:36:46.836962+07	2025-11-05 02:44:46.798806+07	f	\N	2025-11-07 21:37:20.719638+07
9e292436-ba55-4249-9bfc-d838c35aec71	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:36:54.948638+07	2025-11-05 02:36:54.958708+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:36:54.948638+07	2025-11-05 02:36:54.986786+07	2025-11-05 02:44:54.948638+07	f	\N	2025-11-07 21:37:20.719638+07
9c25fa18-d3d7-421e-9fdb-4c2b6298b8ac	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:37:03.293825+07	2025-11-05 02:37:03.303164+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:37:03.293825+07	2025-11-05 02:37:03.334148+07	2025-11-05 02:45:03.293825+07	f	\N	2025-11-07 21:37:20.719638+07
1dd25812-01af-4261-ad83-f0bce08e9de3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:37:01.584182+07	2025-11-05 02:37:03.519704+07	\N	2025-11-04 19:37:00	00:15:00	2025-11-05 02:36:01.584182+07	2025-11-05 02:37:03.540777+07	2025-11-05 02:38:01.584182+07	f	\N	2025-11-07 21:37:20.719638+07
0ed50654-24ab-4160-a386-52ef32b6b6a4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:37:30.551376+07	2025-11-05 02:37:30.568341+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:37:30.551376+07	2025-11-05 02:37:30.60323+07	2025-11-05 02:45:30.551376+07	f	\N	2025-11-07 21:37:20.719638+07
c4c4946b-496d-457e-b19c-59310ee00f8e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:37:38.906827+07	2025-11-05 02:37:38.917166+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:37:38.906827+07	2025-11-05 02:37:38.944827+07	2025-11-05 02:45:38.906827+07	f	\N	2025-11-07 21:37:20.719638+07
ed464daf-15bc-4e9f-819a-8e68d007daa9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:37:49.431385+07	2025-11-05 02:37:49.443982+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:37:49.431385+07	2025-11-05 02:37:49.479165+07	2025-11-05 02:45:49.431385+07	f	\N	2025-11-07 21:37:20.719638+07
747f78fa-6550-46d3-89ac-2f2e595b982e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:37:58.406035+07	2025-11-05 02:37:58.417613+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:37:58.406035+07	2025-11-05 02:37:58.448384+07	2025-11-05 02:45:58.406035+07	f	\N	2025-11-07 21:37:20.719638+07
2d8a3de9-98dc-4920-a5df-d89cbfcf7f24	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:38:01.638965+07	2025-11-05 02:38:02.564331+07	\N	2025-11-04 19:38:00	00:15:00	2025-11-05 02:37:03.638965+07	2025-11-05 02:38:02.591619+07	2025-11-05 02:39:01.638965+07	f	\N	2025-11-07 21:37:20.719638+07
1a9b1bce-de3c-4da8-90e1-4aa2ad73ffc3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:38:07.663888+07	2025-11-05 02:38:07.675177+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:38:07.663888+07	2025-11-05 02:38:07.703947+07	2025-11-05 02:46:07.663888+07	f	\N	2025-11-07 21:37:20.719638+07
63dee3ef-22f3-4d1d-8693-0f2f77af387b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:38:19.157125+07	2025-11-05 02:38:19.167379+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:38:19.157125+07	2025-11-05 02:38:19.205297+07	2025-11-05 02:46:19.157125+07	f	\N	2025-11-07 21:37:20.719638+07
f2fa29df-3043-4e69-866d-9cd245b6382f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:38:27.975425+07	2025-11-05 02:38:27.985066+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:38:27.975425+07	2025-11-05 02:38:28.014062+07	2025-11-05 02:46:27.975425+07	f	\N	2025-11-07 21:37:20.719638+07
7059269c-7e65-4bb2-bf44-5bbcf30d519d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:38:37.284988+07	2025-11-05 02:38:37.296166+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:38:37.284988+07	2025-11-05 02:38:37.330617+07	2025-11-05 02:46:37.284988+07	f	\N	2025-11-07 21:37:20.719638+07
f306fe58-4ba6-48ae-9360-40b67caf8abb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:38:47.727329+07	2025-11-05 02:38:47.737721+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:38:47.727329+07	2025-11-05 02:38:47.766363+07	2025-11-05 02:46:47.727329+07	f	\N	2025-11-07 21:37:20.719638+07
de339184-62f1-40aa-8d6c-ccc2511283af	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:38:57.591246+07	2025-11-05 02:38:57.601743+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:38:57.591246+07	2025-11-05 02:38:57.634877+07	2025-11-05 02:46:57.591246+07	f	\N	2025-11-07 21:37:20.719638+07
a0c1ecdb-bdd3-464a-8075-5c27687b6af9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:39:01.585886+07	2025-11-05 02:39:01.753793+07	\N	2025-11-04 19:39:00	00:15:00	2025-11-05 02:38:02.585886+07	2025-11-05 02:39:01.781152+07	2025-11-05 02:40:01.585886+07	f	\N	2025-11-07 21:37:20.719638+07
c878e808-7519-48e8-b81e-93191bdb427b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:39:08.574333+07	2025-11-05 02:39:08.585361+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:39:08.574333+07	2025-11-05 02:39:08.625886+07	2025-11-05 02:47:08.574333+07	f	\N	2025-11-07 21:37:20.719638+07
616bdc6e-a702-41c1-b296-1d741e0565ec	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:39:20.061158+07	2025-11-05 02:39:20.072439+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:39:20.061158+07	2025-11-05 02:39:20.099007+07	2025-11-05 02:47:20.061158+07	f	\N	2025-11-07 21:37:20.719638+07
e8118d15-6744-491f-bca2-1d06feff258b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:39:31.237528+07	2025-11-05 02:39:31.24784+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:39:31.237528+07	2025-11-05 02:39:31.280769+07	2025-11-05 02:47:31.237528+07	f	\N	2025-11-07 21:37:20.719638+07
4396d608-4aa9-43b5-b9d2-7a42c64e5ff4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:40:21.188534+07	2025-11-05 02:40:21.206055+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:40:21.188534+07	2025-11-05 02:40:21.237633+07	2025-11-05 02:48:21.188534+07	f	\N	2025-11-07 21:37:20.719638+07
ccd019e9-fce2-47b4-84d5-68dc9ab08238	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:40:01.776554+07	2025-11-05 02:40:21.337526+07	\N	2025-11-04 19:40:00	00:15:00	2025-11-05 02:39:01.776554+07	2025-11-05 02:40:21.360766+07	2025-11-05 02:41:01.776554+07	f	\N	2025-11-07 21:37:20.719638+07
2735b53b-29c2-4b3f-b12d-40a112b050be	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:40:54.682078+07	2025-11-05 02:40:54.693305+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:40:54.682078+07	2025-11-05 02:40:54.721845+07	2025-11-05 02:48:54.682078+07	f	\N	2025-11-07 21:37:20.719638+07
fdd9777c-2114-430c-9fa0-acfe2720c2e6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:41:04.572835+07	2025-11-05 02:41:04.582934+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:41:04.572835+07	2025-11-05 02:41:04.613139+07	2025-11-05 02:49:04.572835+07	f	\N	2025-11-07 21:37:20.719638+07
a5390f2b-3e9c-48b8-b513-4e1345ae40bf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:41:01.51329+07	2025-11-05 02:41:04.903397+07	\N	2025-11-04 19:41:00	00:15:00	2025-11-05 02:40:21.51329+07	2025-11-05 02:41:04.927706+07	2025-11-05 02:42:01.51329+07	f	\N	2025-11-07 21:37:20.719638+07
2334fc5d-2d1f-452b-9a02-f199f17d53fd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:41:23.948546+07	2025-11-05 02:41:23.96702+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:41:23.948546+07	2025-11-05 02:41:24.001243+07	2025-11-05 02:49:23.948546+07	f	\N	2025-11-07 21:37:20.719638+07
a5a3e64d-7ad7-4342-a4d4-731d992c7adf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:42:01.091586+07	2025-11-05 02:42:04.16433+07	\N	2025-11-04 19:42:00	00:15:00	2025-11-05 02:41:05.091586+07	2025-11-05 02:42:04.193867+07	2025-11-05 02:43:01.091586+07	f	\N	2025-11-07 21:37:20.719638+07
44acc0dd-d92e-4108-8d62-3b1be8177c16	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:42:45.764845+07	2025-11-05 02:42:45.780747+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:42:45.764845+07	2025-11-05 02:42:45.81047+07	2025-11-05 02:50:45.764845+07	f	\N	2025-11-07 21:37:20.719638+07
cd55aa30-8b8b-4d77-a530-1fa2d21238c1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:43:01.188736+07	2025-11-05 02:43:01.930108+07	\N	2025-11-04 19:43:00	00:15:00	2025-11-05 02:42:04.188736+07	2025-11-05 02:43:01.950858+07	2025-11-05 02:44:01.188736+07	f	\N	2025-11-07 21:37:20.719638+07
6d7c4d10-acd3-4e86-ac86-ec9f11f79da9	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:43:35.819371+07	2025-11-05 02:43:35.832971+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:43:35.819371+07	2025-11-05 02:43:35.8684+07	2025-11-05 02:51:35.819371+07	f	\N	2025-11-07 21:37:20.719638+07
433d9e59-5539-4f0b-8314-1c43d6b14243	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:57:16.967507+07	2025-11-05 02:57:16.985846+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:57:16.967507+07	2025-11-05 02:57:17.028875+07	2025-11-05 03:05:16.967507+07	f	\N	2025-11-07 21:37:20.719638+07
43a23201-5759-400e-9d82-903c4221db8b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:57:17.240219+07	2025-11-05 02:57:21.112933+07	\N	2025-11-04 19:57:00	00:15:00	2025-11-05 02:57:17.240219+07	2025-11-05 02:57:21.138394+07	2025-11-05 02:58:17.240219+07	f	\N	2025-11-07 21:37:20.719638+07
8f0b4d62-1775-466e-a510-75c311719db6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:58:01.133913+07	2025-11-05 02:58:01.183808+07	\N	2025-11-04 19:58:00	00:15:00	2025-11-05 02:57:21.133913+07	2025-11-05 02:58:01.201344+07	2025-11-05 02:59:01.133913+07	f	\N	2025-11-07 21:37:20.719638+07
3e8d88ec-b016-4628-9e7d-ac81b8fed8a1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:58:44.532517+07	2025-11-05 02:58:44.541264+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:58:44.532517+07	2025-11-05 02:58:44.568642+07	2025-11-05 03:06:44.532517+07	f	\N	2025-11-07 21:37:20.719638+07
ffe9aa0f-921d-48c4-9b04-f722e9fc587e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 02:59:01.198153+07	2025-11-05 02:59:04.715577+07	\N	2025-11-04 19:59:00	00:15:00	2025-11-05 02:58:01.198153+07	2025-11-05 02:59:04.743095+07	2025-11-05 03:00:01.198153+07	f	\N	2025-11-07 21:37:20.719638+07
d53755f3-5100-47c6-8091-239bd4609d39	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 02:59:16.547217+07	2025-11-05 02:59:16.558021+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 02:59:16.547217+07	2025-11-05 02:59:16.585451+07	2025-11-05 03:07:16.547217+07	f	\N	2025-11-07 21:37:20.719638+07
d8541b3d-1b93-4ef6-8e01-6b30b3cd73ad	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 03:01:48.328847+07	2025-11-05 03:01:48.349603+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 03:01:48.328847+07	2025-11-05 03:01:48.390503+07	2025-11-05 03:09:48.328847+07	f	\N	2025-11-07 21:37:20.719638+07
26036cc3-6fde-426a-810b-143c28cbed47	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 03:01:48.645586+07	2025-11-05 03:01:52.501585+07	\N	2025-11-04 20:01:00	00:15:00	2025-11-05 03:01:48.645586+07	2025-11-05 03:01:52.523172+07	2025-11-05 03:02:48.645586+07	f	\N	2025-11-07 21:37:20.719638+07
068bd3dd-264d-4c53-a868-39e249a4b0fa	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 03:02:01.517831+07	2025-11-05 03:02:04.535848+07	\N	2025-11-04 20:02:00	00:15:00	2025-11-05 03:01:52.517831+07	2025-11-05 03:02:04.547617+07	2025-11-05 03:03:01.517831+07	f	\N	2025-11-07 21:37:20.719638+07
60778888-b986-47a0-9241-eba8ea17b484	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 03:02:18.664569+07	2025-11-05 03:02:18.677643+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 03:02:18.664569+07	2025-11-05 03:02:18.710898+07	2025-11-05 03:10:18.664569+07	f	\N	2025-11-07 21:37:20.719638+07
221520cc-44a2-45f5-ba99-e923c1369347	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 03:03:01.545035+07	2025-11-05 03:03:03.030529+07	\N	2025-11-04 20:03:00	00:15:00	2025-11-05 03:02:04.545035+07	2025-11-05 03:03:03.062235+07	2025-11-05 03:04:01.545035+07	f	\N	2025-11-07 21:37:20.719638+07
2f4785e5-f164-4a4e-9001-be61946d3b3f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 03:04:01.056863+07	2025-11-05 03:04:03.137399+07	\N	2025-11-04 20:04:00	00:15:00	2025-11-05 03:03:03.056863+07	2025-11-05 03:04:03.157622+07	2025-11-05 03:05:01.056863+07	f	\N	2025-11-07 21:37:20.719638+07
e88a9d77-8863-41d0-8292-cd06c3f76ae0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 03:05:01.152505+07	2025-11-05 03:05:03.256833+07	\N	2025-11-04 20:05:00	00:15:00	2025-11-05 03:04:03.152505+07	2025-11-05 03:05:03.271502+07	2025-11-05 03:06:01.152505+07	f	\N	2025-11-07 21:37:20.719638+07
cee18f93-8fef-47bc-a654-b74cb246848c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 03:04:18.716428+07	2025-11-05 03:05:18.699641+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 03:02:18.716428+07	2025-11-05 03:05:18.721758+07	2025-11-05 03:12:18.716428+07	f	\N	2025-11-07 21:37:20.719638+07
570a8d99-5a00-4e4b-8311-36203b0e4bf9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 03:06:01.269144+07	2025-11-05 03:06:03.377052+07	\N	2025-11-04 20:06:00	00:15:00	2025-11-05 03:05:03.269144+07	2025-11-05 03:06:03.389017+07	2025-11-05 03:07:01.269144+07	f	\N	2025-11-07 21:37:20.719638+07
10935578-a8e7-40fd-81d0-86addc55ccc5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 03:07:01.386584+07	2025-11-05 03:07:03.520191+07	\N	2025-11-04 20:07:00	00:15:00	2025-11-05 03:06:03.386584+07	2025-11-05 03:07:03.534178+07	2025-11-05 03:08:01.386584+07	f	\N	2025-11-07 21:37:20.719638+07
bb580777-8637-4282-9ae5-2c0285165f45	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 03:08:01.532254+07	2025-11-05 03:08:03.638992+07	\N	2025-11-04 20:08:00	00:15:00	2025-11-05 03:07:03.532254+07	2025-11-05 03:08:03.648985+07	2025-11-05 03:09:01.532254+07	f	\N	2025-11-07 21:37:20.719638+07
1cfa878e-adea-4edf-89e9-0992f5074a45	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 03:07:18.725348+07	2025-11-05 03:08:18.722367+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 03:05:18.725348+07	2025-11-05 03:08:18.747196+07	2025-11-05 03:15:18.725348+07	f	\N	2025-11-07 21:37:20.719638+07
3517011b-f5d7-4ca8-8a80-61133f042bbf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 03:09:01.646169+07	2025-11-05 03:09:03.761051+07	\N	2025-11-04 20:09:00	00:15:00	2025-11-05 03:08:03.646169+07	2025-11-05 03:09:03.7686+07	2025-11-05 03:10:01.646169+07	f	\N	2025-11-07 21:37:20.719638+07
d062ef2f-ebfc-46ca-a4b8-62779ffe7e9b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 03:10:01.766769+07	2025-11-05 03:10:03.866675+07	\N	2025-11-04 20:10:00	00:15:00	2025-11-05 03:09:03.766769+07	2025-11-05 03:10:03.87992+07	2025-11-05 03:11:01.766769+07	f	\N	2025-11-07 21:37:20.719638+07
95e8b676-63ae-4335-967a-e296538bc84e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 03:11:01.877276+07	2025-11-05 03:11:03.991411+07	\N	2025-11-04 20:11:00	00:15:00	2025-11-05 03:10:03.877276+07	2025-11-05 03:11:04.010471+07	2025-11-05 03:12:01.877276+07	f	\N	2025-11-07 21:37:20.719638+07
e28013f6-dc10-4b99-890b-1d166ef208e5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-05 03:10:18.751793+07	2025-11-05 03:11:18.729919+07	__pgboss__maintenance	\N	00:15:00	2025-11-05 03:08:18.751793+07	2025-11-05 03:11:18.752927+07	2025-11-05 03:18:18.751793+07	f	\N	2025-11-07 21:37:20.719638+07
0bc714d7-eb17-4a49-99ad-49ba30335570	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 03:12:01.006085+07	2025-11-05 03:12:04.102974+07	\N	2025-11-04 20:12:00	00:15:00	2025-11-05 03:11:04.006085+07	2025-11-05 03:12:04.116646+07	2025-11-05 03:13:01.006085+07	f	\N	2025-11-07 21:37:20.719638+07
e81a8634-73ab-494c-96cb-25236f4e1d3f	__pgboss__cron	0	\N	created	2	0	0	f	2025-11-05 03:14:01.195312+07	\N	\N	2025-11-04 20:14:00	00:15:00	2025-11-05 03:13:04.195312+07	\N	2025-11-05 03:15:01.195312+07	f	\N	2025-11-07 21:37:20.719638+07
daeff19c-f265-4c63-be0f-9aa11010da17	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-05 03:13:01.114523+07	2025-11-05 03:13:04.1831+07	\N	2025-11-04 20:13:00	00:15:00	2025-11-05 03:12:04.114523+07	2025-11-05 03:13:04.198375+07	2025-11-05 03:14:01.114523+07	f	\N	2025-11-07 21:37:20.719638+07
2494be0e-93d6-4b9f-913c-4d2e3a4bbdca	__pgboss__cron	0	\N	created	2	0	0	f	2025-11-07 23:53:01.205325+07	\N	\N	2025-11-07 16:53:00	00:15:00	2025-11-07 23:52:01.205325+07	\N	2025-11-07 23:54:01.205325+07	f	\N	2025-11-08 00:02:25.447817+07
5459c6b4-a4f0-47f7-afb0-0a0ecd7b67e2	__pgboss__cron	0	\N	created	2	0	0	f	2025-11-08 00:09:01.149024+07	\N	\N	2025-11-07 17:09:00	00:15:00	2025-11-08 00:08:57.149024+07	\N	2025-11-08 00:10:01.149024+07	f	\N	2025-11-08 01:02:22.376204+07
\.


--
-- TOC entry 5025 (class 0 OID 305049)
-- Dependencies: 237
-- Data for Name: job; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.job (id, name, priority, data, state, retrylimit, retrycount, retrydelay, retrybackoff, startafter, startedon, singletonkey, singletonon, expirein, createdon, completedon, keepuntil, on_complete, output) FROM stdin;
b32d9f65-f30e-424b-8595-70168ada842a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:38:33.190823+07	2025-11-07 21:38:33.205619+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:38:33.190823+07	2025-11-07 21:38:33.231545+07	2025-11-07 21:46:33.190823+07	f	\N
4448405e-b464-4e67-a44f-509c6357a333	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:10:53.084895+07	2025-11-07 22:10:53.103165+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:10:53.084895+07	2025-11-07 22:10:53.146702+07	2025-11-07 22:18:53.084895+07	f	\N
44b0b941-5f40-49f6-bfa3-e8384f48b187	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:51:01.258715+07	2025-11-07 21:51:01.351016+07	\N	2025-11-07 14:51:00	00:15:00	2025-11-07 21:50:01.258715+07	2025-11-07 21:51:01.367992+07	2025-11-07 21:52:01.258715+07	f	\N
2619b8de-4350-4df8-a5e1-b422566874b1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:51:01.501411+07	2025-11-07 22:51:04.621022+07	\N	2025-11-07 15:51:00	00:15:00	2025-11-07 22:50:04.501411+07	2025-11-07 22:51:04.653807+07	2025-11-07 22:52:01.501411+07	f	\N
e33d6aeb-6e2c-49f0-81dc-392a8489687e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:40:01.455785+07	2025-11-07 21:40:01.671305+07	\N	2025-11-07 14:40:00	00:15:00	2025-11-07 21:39:05.455785+07	2025-11-07 21:40:01.687838+07	2025-11-07 21:41:01.455785+07	f	\N
38362467-5cf1-4e3e-a974-d3d50889b46c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:52:01.364547+07	2025-11-07 21:52:02.879005+07	\N	2025-11-07 14:52:00	00:15:00	2025-11-07 21:51:01.364547+07	2025-11-07 21:52:02.899279+07	2025-11-07 21:53:01.364547+07	f	\N
bf8cb870-0a4a-4941-94c1-773b10a699dd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:25:01.125849+07	2025-11-07 22:25:01.253042+07	\N	2025-11-07 15:25:00	00:15:00	2025-11-07 22:24:01.125849+07	2025-11-07 22:25:01.28415+07	2025-11-07 22:26:01.125849+07	f	\N
f4bb8dc4-98b4-4d55-8bfe-e8b2e124a64f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:45:20.048292+07	2025-11-07 21:45:20.062523+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:45:20.048292+07	2025-11-07 21:45:20.101863+07	2025-11-07 21:53:20.048292+07	f	\N
62748022-84f0-4fca-b8c9-5c3924b0a043	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:41:01.70922+07	2025-11-07 23:41:03.684279+07	\N	2025-11-07 16:41:00	00:15:00	2025-11-07 23:40:02.70922+07	2025-11-07 23:41:03.701848+07	2025-11-07 23:42:01.70922+07	f	\N
5459d0e4-f4fc-4460-b075-b6196931ab88	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 00:03:01.595714+07	2025-11-08 00:03:01.643918+07	\N	2025-11-07 17:03:00	00:15:00	2025-11-08 00:02:29.595714+07	2025-11-08 00:03:01.659389+07	2025-11-08 00:04:01.595714+07	f	\N
70559c29-d6d4-4894-921d-72893fa71d71	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:11:01.116574+07	2025-11-07 22:11:01.290644+07	\N	2025-11-07 15:11:00	00:15:00	2025-11-07 22:10:02.116574+07	2025-11-07 22:11:01.306346+07	2025-11-07 22:12:01.116574+07	f	\N
a1e215b6-208f-4609-b68c-fe3ac7d07702	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:26:01.280324+07	2025-11-07 22:26:01.395071+07	\N	2025-11-07 15:26:00	00:15:00	2025-11-07 22:25:01.280324+07	2025-11-07 22:26:01.40368+07	2025-11-07 22:27:01.280324+07	f	\N
a521cc6d-848c-4f62-963a-940c50b84399	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:12:01.303363+07	2025-11-07 22:12:01.403777+07	\N	2025-11-07 15:12:00	00:15:00	2025-11-07 22:11:01.303363+07	2025-11-07 22:12:01.42157+07	2025-11-07 22:13:01.303363+07	f	\N
8c25996c-a681-4c61-8065-d5dc2808c74e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:19:01.770355+07	2025-11-07 23:19:04.900622+07	\N	2025-11-07 16:19:00	00:15:00	2025-11-07 23:18:04.770355+07	2025-11-07 23:19:04.914072+07	2025-11-07 23:20:01.770355+07	f	\N
99a813a8-9be3-4978-a776-c453696efe91	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:27:01.090446+07	2025-11-08 01:27:02.178498+07	\N	2025-11-07 18:27:00	00:15:00	2025-11-08 01:26:02.090446+07	2025-11-08 01:27:02.197215+07	2025-11-08 01:28:01.090446+07	f	\N
7da5c1f4-b544-4ff0-aef8-45a83840cc07	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:18:24.327086+07	2025-11-07 22:18:24.340247+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:18:24.327086+07	2025-11-07 22:18:24.372707+07	2025-11-07 22:26:24.327086+07	f	\N
93778a0e-c799-4c03-bf4f-359abb412457	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:27:01.401604+07	2025-11-07 22:27:01.519219+07	\N	2025-11-07 15:27:00	00:15:00	2025-11-07 22:26:01.401604+07	2025-11-07 22:27:01.530882+07	2025-11-07 22:28:01.401604+07	f	\N
a2a2bf2d-83f4-49f3-ac6b-5b9c4983f007	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:44:59.303693+07	2025-11-07 23:44:59.558258+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:44:59.303693+07	2025-11-07 23:45:00.181343+07	2025-11-07 23:52:59.303693+07	f	\N
abdaf610-6b4f-4ad0-8356-56b6c5f06714	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:28:01.528731+07	2025-11-07 22:28:01.619083+07	\N	2025-11-07 15:28:00	00:15:00	2025-11-07 22:27:01.528731+07	2025-11-07 22:28:01.629556+07	2025-11-07 22:29:01.528731+07	f	\N
5a2edb59-5ea5-4063-96d0-05f6309301a8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:20:01.910609+07	2025-11-07 23:20:05.01794+07	\N	2025-11-07 16:20:00	00:15:00	2025-11-07 23:19:04.910609+07	2025-11-07 23:20:05.045819+07	2025-11-07 23:21:01.910609+07	f	\N
1698dbfa-0095-49a8-a3a4-e029c49e2849	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:19:44.115115+07	2025-11-07 23:20:44.106666+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:17:44.115115+07	2025-11-07 23:20:44.149574+07	2025-11-07 23:27:44.115115+07	f	\N
2a23dea5-2ef7-457b-8c05-20f36cd3eead	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:30:01.747205+07	2025-11-07 22:30:01.87365+07	\N	2025-11-07 15:30:00	00:15:00	2025-11-07 22:29:01.747205+07	2025-11-07 22:30:01.901867+07	2025-11-07 22:31:01.747205+07	f	\N
a3897f5e-bf71-4a02-9500-caa9f662b82f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:21:01.040111+07	2025-11-07 23:21:01.117992+07	\N	2025-11-07 16:21:00	00:15:00	2025-11-07 23:20:05.040111+07	2025-11-07 23:21:01.141484+07	2025-11-07 23:22:01.040111+07	f	\N
21eded83-9a67-421e-acb5-50b61743a6a1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:30:08.318633+07	2025-11-07 22:30:08.319616+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:28:08.318633+07	2025-11-07 22:30:08.34324+07	2025-11-07 22:38:08.318633+07	f	\N
0dfa432f-9b6c-4461-8818-185421a9298d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 00:06:01.986611+07	2025-11-08 00:06:02.073324+07	\N	2025-11-07 17:06:00	00:15:00	2025-11-08 00:05:01.986611+07	2025-11-08 00:06:02.091473+07	2025-11-08 00:07:01.986611+07	f	\N
0d8bf99d-1080-427c-813a-b7c75f16362d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:48:41.809967+07	2025-11-07 23:48:41.819294+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:48:41.809967+07	2025-11-07 23:48:41.845443+07	2025-11-07 23:56:41.809967+07	f	\N
1dd54d5c-1dc3-4a38-8248-e5af8704c811	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:31:01.898937+07	2025-11-07 22:31:01.990023+07	\N	2025-11-07 15:31:00	00:15:00	2025-11-07 22:30:01.898937+07	2025-11-07 22:31:01.999884+07	2025-11-07 22:32:01.898937+07	f	\N
3247d85a-6abb-4e8f-b477-f666ccbd542c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:30:01.300426+07	2025-11-07 23:30:02.132722+07	\N	2025-11-07 16:30:00	00:15:00	2025-11-07 23:29:02.300426+07	2025-11-07 23:30:02.145147+07	2025-11-07 23:31:01.300426+07	f	\N
345a69f6-5955-40d0-9f8f-1a05ab50f319	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:32:01.996859+07	2025-11-07 22:32:02.111307+07	\N	2025-11-07 15:32:00	00:15:00	2025-11-07 22:31:01.996859+07	2025-11-07 22:32:02.126471+07	2025-11-07 22:33:01.996859+07	f	\N
dedfc399-0890-4c86-81cd-d3848d5924b9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:30:01.436607+07	2025-11-08 01:30:02.547781+07	\N	2025-11-07 18:30:00	00:15:00	2025-11-08 01:29:02.436607+07	2025-11-08 01:30:02.58701+07	2025-11-08 01:31:01.436607+07	f	\N
8f0577e2-c8f7-41c7-bb62-c2da517c9988	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:39:18.397286+07	2025-11-07 23:39:18.407088+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:39:18.397286+07	2025-11-07 23:39:18.433508+07	2025-11-07 23:47:18.397286+07	f	\N
64e5dd9e-e2a9-4b9c-9bed-65ae43139799	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 00:08:01.256235+07	2025-11-08 00:08:56.716082+07	\N	2025-11-07 17:08:00	00:15:00	2025-11-08 00:07:02.256235+07	2025-11-08 00:08:56.739505+07	2025-11-08 00:09:01.256235+07	f	\N
9c58aff7-c383-4043-ac4c-a54f6b3ae5da	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:33:04.773893+07	2025-11-08 01:34:04.755365+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:31:04.773893+07	2025-11-08 01:34:04.770044+07	2025-11-08 01:41:04.773893+07	f	\N
a0b04fa8-0bb1-4243-a5df-3a3721a7d567	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:12:01.294814+07	2025-11-08 01:12:04.33152+07	\N	2025-11-07 18:12:00	00:15:00	2025-11-08 01:11:02.294814+07	2025-11-08 01:12:04.346929+07	2025-11-08 01:13:01.294814+07	f	\N
20369da6-4e00-4c1d-ad80-9cd01ff3d82f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:36:01.091167+07	2025-11-08 01:36:03.177386+07	\N	2025-11-07 18:36:00	00:15:00	2025-11-08 01:35:03.091167+07	2025-11-08 01:36:03.187563+07	2025-11-08 01:37:01.091167+07	f	\N
eae7d764-64c4-4f59-ab7a-ae173e990d1d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:42:41.650733+07	2025-11-08 01:42:41.674502+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:42:41.650733+07	2025-11-08 01:42:41.717658+07	2025-11-08 01:50:41.650733+07	f	\N
9d759173-1e35-4a6c-95c0-0dda44b40618	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:44:01.903799+07	2025-11-08 01:44:02.029828+07	\N	2025-11-07 18:44:00	00:15:00	2025-11-08 01:43:01.903799+07	2025-11-08 01:44:02.051098+07	2025-11-08 01:45:01.903799+07	f	\N
50dfaf7d-0bb0-4f97-a712-8b4e6f3090b7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:44:41.726447+07	2025-11-08 01:45:41.692336+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:42:41.726447+07	2025-11-08 01:45:41.713972+07	2025-11-08 01:52:41.726447+07	f	\N
82e5ee1a-8931-4da9-9a94-9920f3b7d1ec	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:46:01.12862+07	2025-11-08 01:46:02.224571+07	\N	2025-11-07 18:46:00	00:15:00	2025-11-08 01:45:02.12862+07	2025-11-08 01:46:02.253998+07	2025-11-08 01:47:01.12862+07	f	\N
ab9e6d74-b600-4c08-b0f1-c6b78dfacc63	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:39:25.394862+07	2025-11-07 21:39:25.40695+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:39:25.394862+07	2025-11-07 21:39:25.435835+07	2025-11-07 21:47:25.394862+07	f	\N
e37ecd13-db0f-479b-8714-fe5e842bbe59	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:13:01.418062+07	2025-11-07 22:13:05.315449+07	\N	2025-11-07 15:13:00	00:15:00	2025-11-07 22:12:01.418062+07	2025-11-07 22:13:05.335822+07	2025-11-07 22:14:01.418062+07	f	\N
0f6ded2e-9946-40dd-af0e-19b67744bcef	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:22:44.157696+07	2025-11-07 23:23:44.144679+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:20:44.157696+07	2025-11-07 23:23:44.171872+07	2025-11-07 23:30:44.157696+07	f	\N
54aeafc7-7d4a-4fb4-8392-18337e56c052	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:27:08.315773+07	2025-11-07 22:28:08.303796+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:25:08.315773+07	2025-11-07 22:28:08.315235+07	2025-11-07 22:35:08.315773+07	f	\N
a8aa0b90-decf-4336-b212-33621e4d1080	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:45:41.723735+07	2025-11-07 21:45:41.737495+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:45:41.723735+07	2025-11-07 21:45:41.775141+07	2025-11-07 21:53:41.723735+07	f	\N
3449a3ff-bb64-4bde-95b2-88289660b7db	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:18:31.746174+07	2025-11-07 22:18:31.755639+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:18:31.746174+07	2025-11-07 22:18:31.783434+07	2025-11-07 22:26:31.746174+07	f	\N
7de29814-28ef-45c5-be49-accc12800832	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:52:01.649908+07	2025-11-07 22:52:04.870502+07	\N	2025-11-07 15:52:00	00:15:00	2025-11-07 22:51:04.649908+07	2025-11-07 22:52:04.902683+07	2025-11-07 22:53:01.649908+07	f	\N
f17e26ab-52eb-4f96-a9f5-01d0517d1ec6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:29:01.626895+07	2025-11-07 22:29:01.733524+07	\N	2025-11-07 15:29:00	00:15:00	2025-11-07 22:28:01.626895+07	2025-11-07 22:29:01.750125+07	2025-11-07 22:30:01.626895+07	f	\N
f4764f0b-5762-4337-83db-5e541d4f2047	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:40:27.586326+07	2025-11-07 23:40:27.598474+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:40:27.586326+07	2025-11-07 23:40:27.628775+07	2025-11-07 23:48:27.586326+07	f	\N
d7b635b6-48f5-46d0-a814-ad0f84b1a67f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:20:01.095516+07	2025-11-07 22:20:04.548988+07	\N	2025-11-07 15:20:00	00:15:00	2025-11-07 22:19:04.095516+07	2025-11-07 22:20:04.571224+07	2025-11-07 22:21:01.095516+07	f	\N
0846c2c4-b7d9-4ef2-887c-45c2af359868	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 00:04:01.656034+07	2025-11-08 00:04:01.783125+07	\N	2025-11-07 17:04:00	00:15:00	2025-11-08 00:03:01.656034+07	2025-11-08 00:04:01.80769+07	2025-11-08 00:05:01.656034+07	f	\N
4404da91-a754-437e-9665-567034816ae2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:32:08.346893+07	2025-11-07 22:33:08.342312+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:30:08.346893+07	2025-11-07 22:33:08.358512+07	2025-11-07 22:40:08.346893+07	f	\N
2bb58d17-cc2b-4460-a061-1f401ad50518	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:53:01.897084+07	2025-11-07 22:53:04.968021+07	\N	2025-11-07 15:53:00	00:15:00	2025-11-07 22:52:04.897084+07	2025-11-07 22:53:04.977014+07	2025-11-07 22:54:01.897084+07	f	\N
50bbee29-5407-4066-8dcb-0b85a1e41a1d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:29:40.534712+07	2025-11-07 23:29:40.546624+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:29:40.534712+07	2025-11-07 23:29:40.583374+07	2025-11-07 23:37:40.534712+07	f	\N
1f68d554-4a57-47b5-a7cd-d875594384cf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:54:01.974706+07	2025-11-07 22:54:05.149737+07	\N	2025-11-07 15:54:00	00:15:00	2025-11-07 22:53:04.974706+07	2025-11-07 22:54:05.304455+07	2025-11-07 22:55:01.974706+07	f	\N
9eb0b84c-3031-4088-8eb3-e603f383d5ab	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:28:04.716338+07	2025-11-08 01:29:04.70435+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:26:04.716338+07	2025-11-08 01:29:04.721787+07	2025-11-08 01:36:04.716338+07	f	\N
04b6991c-5d1a-4923-893a-76aae349101b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:45:02.030263+07	2025-11-07 23:45:07.837209+07	\N	2025-11-07 16:46:00	00:15:00	2025-11-07 23:45:00.030263+07	2025-11-07 23:45:07.855886+07	2025-11-07 23:46:02.030263+07	f	\N
32fa1609-3ddd-4e55-befc-d7d0238402ac	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 00:07:01.088525+07	2025-11-08 00:07:02.189937+07	\N	2025-11-07 17:07:00	00:15:00	2025-11-08 00:06:02.088525+07	2025-11-08 00:07:02.265758+07	2025-11-08 00:08:01.088525+07	f	\N
82317ca4-b2f2-4196-b233-c5c6b93cfc6e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:48:58.373061+07	2025-11-07 23:48:58.385715+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:48:58.373061+07	2025-11-07 23:48:58.414847+07	2025-11-07 23:56:58.373061+07	f	\N
7dfc8258-108f-445c-9b38-1e374edabd7d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:11:40.164829+07	2025-11-08 01:11:40.17448+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:11:40.164829+07	2025-11-08 01:11:40.197759+07	2025-11-08 01:19:40.164829+07	f	\N
ebc23c3d-ab48-4d1b-ae07-1b441ae10775	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:31:01.567106+07	2025-11-08 01:31:02.660333+07	\N	2025-11-07 18:31:00	00:15:00	2025-11-08 01:30:02.567106+07	2025-11-08 01:31:02.673194+07	2025-11-08 01:32:01.567106+07	f	\N
871aa9d9-7081-4d57-9f67-bc08dab57c96	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:13:40.201589+07	2025-11-08 01:14:40.200119+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:11:40.201589+07	2025-11-08 01:14:40.218291+07	2025-11-08 01:21:40.201589+07	f	\N
731cfef8-272e-45d2-a042-ea247443aee4	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:31:04.724226+07	2025-11-08 01:31:04.739899+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:29:04.724226+07	2025-11-08 01:31:04.770796+07	2025-11-08 01:39:04.724226+07	f	\N
e3401e6a-7b67-4333-b8ad-3f6690004c67	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:16:01.663749+07	2025-11-08 01:16:02.510781+07	\N	2025-11-07 18:16:00	00:15:00	2025-11-08 01:15:04.663749+07	2025-11-08 01:16:02.525969+07	2025-11-08 01:17:01.663749+07	f	\N
cbb32bac-68b8-4833-9c52-7a515cd12ae2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:32:01.669758+07	2025-11-08 01:32:02.750318+07	\N	2025-11-07 18:32:00	00:15:00	2025-11-08 01:31:02.669758+07	2025-11-08 01:32:02.760469+07	2025-11-08 01:33:01.669758+07	f	\N
08142c75-618c-43fd-a42e-c86bbf5578c5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:33:01.758194+07	2025-11-08 01:33:02.873992+07	\N	2025-11-07 18:33:00	00:15:00	2025-11-08 01:32:02.758194+07	2025-11-08 01:33:02.89242+07	2025-11-08 01:34:01.758194+07	f	\N
5548c1b9-effe-438a-94cd-8710ea7ebfeb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:35:01.99566+07	2025-11-08 01:35:03.078089+07	\N	2025-11-07 18:35:00	00:15:00	2025-11-08 01:34:02.99566+07	2025-11-08 01:35:03.093677+07	2025-11-08 01:36:01.99566+07	f	\N
af448a7c-504d-4dc1-ba14-a01fe11261cb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:36:04.773827+07	2025-11-08 01:36:04.779832+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:34:04.773827+07	2025-11-08 01:36:04.813295+07	2025-11-08 01:44:04.773827+07	f	\N
51b15adc-aeb8-4293-a823-13ff3b7ef895	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:37:01.184635+07	2025-11-08 01:37:03.298282+07	\N	2025-11-07 18:37:00	00:15:00	2025-11-08 01:36:03.184635+07	2025-11-08 01:37:03.316548+07	2025-11-08 01:38:01.184635+07	f	\N
21230a1e-a1d4-4d08-aa62-04ee00dbc5f0	area-xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762540974285-BangToaDo_2025.xls", "userId": 3, "districtId": "b246ae91-2e2e-4f29-8a6b-29be23b6e663", "provinceId": "f851f9a1-330b-4d29-98ae-f4092e7e7f70", "originalname": "BangToaDo_2025.xls"}	completed	0	0	0	f	2025-11-08 01:42:54.292158+07	2025-11-08 01:42:56.19857+07	\N	\N	00:15:00	2025-11-08 01:42:54.292158+07	2025-11-08 01:42:56.573393+07	2025-11-22 01:42:54.292158+07	f	{"created": 1, "skipped": 0, "totalRows": 1, "duplicates": 0, "skippedRows": [], "notConverted": 0}
1796a313-8445-408c-9620-1ecb1c8ef720	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:45:01.048348+07	2025-11-08 01:45:02.117026+07	\N	2025-11-07 18:45:00	00:15:00	2025-11-08 01:44:02.048348+07	2025-11-08 01:45:02.13363+07	2025-11-08 01:46:01.048348+07	f	\N
afe46582-c58d-4fe2-af3a-2d41146e356f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:41:01.68337+07	2025-11-07 21:41:04.760186+07	\N	2025-11-07 14:41:00	00:15:00	2025-11-07 21:40:01.68337+07	2025-11-07 21:41:04.771575+07	2025-11-07 21:42:01.68337+07	f	\N
1ae4a6a9-44dc-437f-a026-7d1f0566365e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:51:58.731748+07	2025-11-07 21:51:58.745788+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:51:58.731748+07	2025-11-07 21:51:58.777739+07	2025-11-07 21:59:58.731748+07	f	\N
5fe7d6e2-134c-49be-99db-b6b98a9a97cd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:13:01.081413+07	2025-11-07 22:13:01.102352+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:13:01.081413+07	2025-11-07 22:13:01.138923+07	2025-11-07 22:21:01.081413+07	f	\N
5bf02f20-1c80-46c8-92b2-fac8a4a7f135	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:45:48.55498+07	2025-11-07 21:45:48.56386+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:45:48.55498+07	2025-11-07 21:45:48.58711+07	2025-11-07 21:53:48.55498+07	f	\N
b6954a45-a52d-47ea-834e-efbb2e8db7e3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:22:01.137036+07	2025-11-07 23:22:01.233848+07	\N	2025-11-07 16:22:00	00:15:00	2025-11-07 23:21:01.137036+07	2025-11-07 23:22:01.273649+07	2025-11-07 23:23:01.137036+07	f	\N
7240d3dc-2302-4d90-aecd-0cc18b9b5def	area-xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762529553544-BangToaDo_2025.xls", "userId": 3, "districtId": "b246ae91-2e2e-4f29-8a6b-29be23b6e663", "provinceId": "f851f9a1-330b-4d29-98ae-f4092e7e7f70", "originalname": "BangToaDo_2025.xls"}	completed	0	0	0	f	2025-11-07 22:32:33.580787+07	2025-11-07 22:32:33.747159+07	\N	\N	00:15:00	2025-11-07 22:32:33.580787+07	2025-11-07 22:32:34.503986+07	2025-11-21 22:32:33.580787+07	f	{"created": 4, "skipped": 0, "totalRows": 4, "duplicates": 0, "skippedRows": [], "notConverted": 0}
f20e4c62-302a-4816-8384-15f70930dad8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:47:48.590912+07	2025-11-07 21:48:48.588203+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:45:48.590912+07	2025-11-07 21:48:48.622172+07	2025-11-07 21:55:48.590912+07	f	\N
a3411ec1-f5ec-42c2-b41d-a3377338057c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:40:36.969228+07	2025-11-07 23:40:36.981296+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:40:36.969228+07	2025-11-07 23:40:37.018459+07	2025-11-07 23:48:36.969228+07	f	\N
c0497f26-e55f-4829-b23c-1dfa5c1073a2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:19:08.225239+07	2025-11-07 22:19:08.236773+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:19:08.225239+07	2025-11-07 22:19:08.272244+07	2025-11-07 22:27:08.225239+07	f	\N
d5e50364-bda0-43b8-b476-0871fa241549	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:33:01.122397+07	2025-11-07 22:33:02.449418+07	\N	2025-11-07 15:33:00	00:15:00	2025-11-07 22:32:02.122397+07	2025-11-07 22:33:02.462641+07	2025-11-07 22:34:01.122397+07	f	\N
a5efcbe6-3462-4e3e-9a36-7114135f1378	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:55:01.292179+07	2025-11-07 22:55:05.252588+07	\N	2025-11-07 15:55:00	00:15:00	2025-11-07 22:54:05.292179+07	2025-11-07 22:55:05.265995+07	2025-11-07 22:56:01.292179+07	f	\N
23ad81fe-eb31-4291-b4f9-0f6a64f62869	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:21:08.278114+07	2025-11-07 22:22:08.264625+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:19:08.278114+07	2025-11-07 22:22:08.290897+07	2025-11-07 22:29:08.278114+07	f	\N
aa955908-5c94-4b9b-bce2-a630893a7b0c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 00:05:01.802127+07	2025-11-08 00:05:01.954564+07	\N	2025-11-07 17:05:00	00:15:00	2025-11-08 00:04:01.802127+07	2025-11-08 00:05:01.991652+07	2025-11-08 00:06:01.802127+07	f	\N
c9f71add-bf17-4e7c-8759-4dd8d6dd347e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:35:01.612872+07	2025-11-07 22:35:02.701885+07	\N	2025-11-07 15:35:00	00:15:00	2025-11-07 22:34:02.612872+07	2025-11-07 22:35:02.754489+07	2025-11-07 22:36:01.612872+07	f	\N
954729d6-2747-4871-8e3a-09f985ea9a0e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:54:08.529821+07	2025-11-07 22:55:08.511993+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:52:08.529821+07	2025-11-07 22:55:08.53177+07	2025-11-07 23:02:08.529821+07	f	\N
106fa30f-3530-4943-a9d7-d9618be87cc3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:29:49.977054+07	2025-11-07 23:29:49.98724+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:29:49.977054+07	2025-11-07 23:29:50.012201+07	2025-11-07 23:37:49.977054+07	f	\N
35b725da-99a6-4498-ae3a-f03809e7167b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:37:01.8186+07	2025-11-07 22:37:02.923591+07	\N	2025-11-07 15:37:00	00:15:00	2025-11-07 22:36:02.8186+07	2025-11-07 22:37:02.93412+07	2025-11-07 22:38:01.8186+07	f	\N
f880e983-93bc-4286-9550-eb095179c226	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:28:01.193387+07	2025-11-08 01:28:02.287802+07	\N	2025-11-07 18:28:00	00:15:00	2025-11-08 01:27:02.193387+07	2025-11-08 01:28:02.301476+07	2025-11-08 01:29:01.193387+07	f	\N
b6fa1193-6cc5-4646-a689-a0e9e38e3091	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:56:01.262861+07	2025-11-07 22:56:01.633463+07	\N	2025-11-07 15:56:00	00:15:00	2025-11-07 22:55:05.262861+07	2025-11-07 22:56:01.657585+07	2025-11-07 22:57:01.262861+07	f	\N
4ae860fd-ded3-4c74-aeea-43bbe3f0ff7c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:38:01.931961+07	2025-11-07 22:38:03.048406+07	\N	2025-11-07 15:38:00	00:15:00	2025-11-07 22:37:02.931961+07	2025-11-07 22:38:03.05719+07	2025-11-07 22:39:01.931961+07	f	\N
ab5b2301-f874-4a9d-b696-923d8475de6a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:46:56.19845+07	2025-11-07 23:46:56.215282+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:46:56.19845+07	2025-11-07 23:46:56.251729+07	2025-11-07 23:54:56.19845+07	f	\N
2d8e7c1f-caec-4e09-8125-c6559d207098	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:39:01.05512+07	2025-11-07 22:39:03.17759+07	\N	2025-11-07 15:39:00	00:15:00	2025-11-07 22:38:03.05512+07	2025-11-07 22:39:03.221952+07	2025-11-07 22:40:01.05512+07	f	\N
dad8cce0-c2b8-4014-9e51-278613773e96	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:57:01.654702+07	2025-11-07 22:57:01.744375+07	\N	2025-11-07 15:57:00	00:15:00	2025-11-07 22:56:01.654702+07	2025-11-07 22:57:01.766707+07	2025-11-07 22:58:01.654702+07	f	\N
2ca24e4a-49d2-41bf-bd86-16773d6fc6c6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:02:22.321714+07	2025-11-08 01:02:22.345955+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:02:22.321714+07	2025-11-08 01:02:22.401955+07	2025-11-08 01:10:22.321714+07	f	\N
0896a7e1-0630-4a5d-926b-bb2bba55d393	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:57:08.534416+07	2025-11-07 22:57:08.539546+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:55:08.534416+07	2025-11-07 22:57:08.555765+07	2025-11-07 23:05:08.534416+07	f	\N
1f1144cc-e232-4149-9ba3-88290991b77e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:31:01.142743+07	2025-11-07 23:31:03.266102+07	\N	2025-11-07 16:31:00	00:15:00	2025-11-07 23:30:02.142743+07	2025-11-07 23:31:03.366689+07	2025-11-07 23:32:01.142743+07	f	\N
20faa766-f868-4296-bc0a-916751237d76	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:29:01.295958+07	2025-11-08 01:29:02.426853+07	\N	2025-11-07 18:29:00	00:15:00	2025-11-08 01:28:02.295958+07	2025-11-08 01:29:02.439025+07	2025-11-08 01:30:01.295958+07	f	\N
4bf4a822-3263-4575-93d6-9ec5721a2b3d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:00:01.994584+07	2025-11-07 23:00:02.677439+07	\N	2025-11-07 16:00:00	00:15:00	2025-11-07 22:59:01.994584+07	2025-11-07 23:00:02.742951+07	2025-11-07 23:01:01.994584+07	f	\N
f692c3f2-c11f-4330-8ab2-14c45db6e531	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:49:54.257587+07	2025-11-07 23:49:54.265775+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:49:54.257587+07	2025-11-07 23:49:54.292415+07	2025-11-07 23:57:54.257587+07	f	\N
c1aefdce-74c5-4e0a-9d2c-adb715f557be	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:59:08.559118+07	2025-11-07 23:00:08.561266+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:57:08.559118+07	2025-11-07 23:00:08.598233+07	2025-11-07 23:07:08.559118+07	f	\N
c06f2361-ff9d-4999-9b9c-5a8fcbd90dd6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:13:01.343229+07	2025-11-08 01:13:04.463099+07	\N	2025-11-07 18:13:00	00:15:00	2025-11-08 01:12:04.343229+07	2025-11-08 01:13:04.472828+07	2025-11-08 01:14:01.343229+07	f	\N
77f7c905-d20a-47cb-8483-16ad51d32faf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:34:01.888261+07	2025-11-08 01:34:02.98341+07	\N	2025-11-07 18:34:00	00:15:00	2025-11-08 01:33:02.888261+07	2025-11-08 01:34:02.998611+07	2025-11-08 01:35:01.888261+07	f	\N
33106b2e-1dc5-4f26-9cb9-06c5d8cb496f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:14:01.470392+07	2025-11-08 01:14:04.552673+07	\N	2025-11-07 18:14:00	00:15:00	2025-11-08 01:13:04.470392+07	2025-11-08 01:14:04.586843+07	2025-11-08 01:15:01.470392+07	f	\N
45231d5b-473d-444b-8dfe-ba41e6d34234	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:47:01.242211+07	2025-11-08 01:47:02.012921+07	\N	2025-11-07 18:47:00	00:15:00	2025-11-08 01:46:02.242211+07	2025-11-08 01:47:02.03605+07	2025-11-08 01:48:01.242211+07	f	\N
06164753-9036-47c8-9b7a-635a8af3df89	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:50:01.115863+07	2025-11-07 21:50:01.242636+07	\N	2025-11-07 14:50:00	00:15:00	2025-11-07 21:49:01.115863+07	2025-11-07 21:50:01.262485+07	2025-11-07 21:51:01.115863+07	f	\N
3dc6d59b-373b-4f0a-80ee-60e6cfbd594e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:40:48.580795+07	2025-11-07 21:40:48.594774+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:40:48.580795+07	2025-11-07 21:40:48.622998+07	2025-11-07 21:48:48.580795+07	f	\N
09d8ac76-d628-4fb9-b57b-28fc7a0aba0f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:24:01.006535+07	2025-11-07 22:24:01.118426+07	\N	2025-11-07 15:24:00	00:15:00	2025-11-07 22:23:05.006535+07	2025-11-07 22:24:01.12929+07	2025-11-07 22:25:01.006535+07	f	\N
0e855aff-c291-4c41-a32d-b75e67085041	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:50:48.626282+07	2025-11-07 21:51:48.609317+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:48:48.626282+07	2025-11-07 21:51:48.622761+07	2025-11-07 21:58:48.626282+07	f	\N
09012e85-218e-4f23-a666-095f2dd98cda	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:14:01.792628+07	2025-11-07 22:14:02.281144+07	\N	2025-11-07 15:14:00	00:15:00	2025-11-07 22:13:01.792628+07	2025-11-07 22:14:02.295842+07	2025-11-07 22:15:01.792628+07	f	\N
3eeeda46-e52e-4cc3-ab0e-8829221808d7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:42:01.769201+07	2025-11-07 21:42:04.868794+07	\N	2025-11-07 14:42:00	00:15:00	2025-11-07 21:41:04.769201+07	2025-11-07 21:42:04.89238+07	2025-11-07 21:43:01.769201+07	f	\N
1d6f2bf3-f634-4f2a-b70c-dfdddc03ded7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:53:01.894711+07	2025-11-07 21:53:04.065125+07	\N	2025-11-07 14:53:00	00:15:00	2025-11-07 21:52:02.894711+07	2025-11-07 21:53:04.083053+07	2025-11-07 21:54:01.894711+07	f	\N
63a1d2ac-18fa-496f-adde-b5044c6999f2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:40:48.771103+07	2025-11-07 23:40:48.782706+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:40:48.771103+07	2025-11-07 23:40:48.811568+07	2025-11-07 23:48:48.771103+07	f	\N
1919f5ab-2472-444d-9b0b-0026869b68db	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:47:01.803702+07	2025-11-07 21:47:04.922486+07	\N	2025-11-07 14:47:00	00:15:00	2025-11-07 21:46:04.803702+07	2025-11-07 21:47:04.933189+07	2025-11-07 21:48:01.803702+07	f	\N
f7037476-5ba0-4fa0-8043-0db69eb3ce8a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:21:01.567752+07	2025-11-07 22:21:04.728508+07	\N	2025-11-07 15:21:00	00:15:00	2025-11-07 22:20:04.567752+07	2025-11-07 22:21:04.753273+07	2025-11-07 22:22:01.567752+07	f	\N
2b47baf7-eec7-43b3-b394-2f7dd2e41e51	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:48:01.930315+07	2025-11-07 21:48:05.025632+07	\N	2025-11-07 14:48:00	00:15:00	2025-11-07 21:47:04.930315+07	2025-11-07 21:48:05.046884+07	2025-11-07 21:49:01.930315+07	f	\N
225f9c92-6502-4578-b2d6-246a1e0a241e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:58:01.761904+07	2025-11-07 22:58:01.858043+07	\N	2025-11-07 15:58:00	00:15:00	2025-11-07 22:57:01.761904+07	2025-11-07 22:58:01.873433+07	2025-11-07 22:59:01.761904+07	f	\N
10209e18-af55-4b9a-b052-f9ad36e50bc5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:23:01.267132+07	2025-11-07 23:23:01.355231+07	\N	2025-11-07 16:23:00	00:15:00	2025-11-07 23:22:01.267132+07	2025-11-07 23:23:01.376221+07	2025-11-07 23:24:01.267132+07	f	\N
c8006ec1-0a58-4280-9dce-a8f362d9ad35	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:34:01.457843+07	2025-11-07 22:34:02.603506+07	\N	2025-11-07 15:34:00	00:15:00	2025-11-07 22:33:02.457843+07	2025-11-07 22:34:02.615634+07	2025-11-07 22:35:01.457843+07	f	\N
94657107-e769-4143-a63e-2ea77f8bc247	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:59:01.870935+07	2025-11-07 22:59:01.983084+07	\N	2025-11-07 15:59:00	00:15:00	2025-11-07 22:58:01.870935+07	2025-11-07 22:59:01.997254+07	2025-11-07 23:00:01.870935+07	f	\N
09f1afbc-61aa-4305-8c5c-e122a0f7519d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:35:08.36178+07	2025-11-07 22:36:08.357491+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:33:08.36178+07	2025-11-07 22:36:08.378882+07	2025-11-07 22:43:08.36178+07	f	\N
0f4a860d-ef0e-47e6-b772-366d7e842c7a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 00:08:56.536285+07	2025-11-08 00:08:56.556788+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 00:08:56.536285+07	2025-11-08 00:08:56.593297+07	2025-11-08 00:16:56.536285+07	f	\N
c0bea934-e5a1-4e1b-b7c1-e07246f79756	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:24:01.371138+07	2025-11-07 23:24:01.440676+07	\N	2025-11-07 16:24:00	00:15:00	2025-11-07 23:23:01.371138+07	2025-11-07 23:24:01.464994+07	2025-11-07 23:25:01.371138+07	f	\N
d04c669d-ca82-4733-af6d-971f5c2575f7	area-xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762531173388-BangToaDo_2025.xls", "userId": 3, "districtId": "40ebf59b-c17e-43a6-a2cd-1f8c77daae92", "provinceId": "f851f9a1-330b-4d29-98ae-f4092e7e7f70", "originalname": "BangToaDo_2025.xls"}	completed	0	0	0	f	2025-11-07 22:59:33.404803+07	2025-11-07 22:59:33.94747+07	\N	\N	00:15:00	2025-11-07 22:59:33.404803+07	2025-11-07 22:59:35.188144+07	2025-11-21 22:59:33.404803+07	f	{"created": 99, "skipped": 0, "totalRows": 99, "duplicates": 0, "skippedRows": [], "notConverted": 0}
d5aae822-8f7a-4fd8-9647-12b0918f3ac0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:38:01.311752+07	2025-11-08 01:38:21.23227+07	\N	2025-11-07 18:38:00	00:15:00	2025-11-08 01:37:03.311752+07	2025-11-08 01:38:21.258794+07	2025-11-08 01:39:01.311752+07	f	\N
42e0e8d5-6cb3-4524-9674-45045f47e525	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:30:39.026128+07	2025-11-07 23:30:39.036596+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:30:39.026128+07	2025-11-07 23:30:39.063489+07	2025-11-07 23:38:39.026128+07	f	\N
cf5ca134-a7bf-4763-accc-065729fb7ef5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:01:01.71098+07	2025-11-07 23:01:02.784179+07	\N	2025-11-07 16:01:00	00:15:00	2025-11-07 23:00:02.71098+07	2025-11-07 23:01:02.815628+07	2025-11-07 23:02:01.71098+07	f	\N
14eb28d3-af52-4016-87b9-07af1d15bd76	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:47:01.517406+07	2025-11-07 23:47:10.499278+07	\N	2025-11-07 16:47:00	00:15:00	2025-11-07 23:46:56.517406+07	2025-11-07 23:47:10.533365+07	2025-11-07 23:48:01.517406+07	f	\N
0b0be35e-d9dc-4e2b-a648-1c52ca0fbcad	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:02:08.600657+07	2025-11-07 23:03:08.576126+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:00:08.600657+07	2025-11-07 23:03:08.595103+07	2025-11-07 23:10:08.600657+07	f	\N
82f5682d-59d5-4d64-8ba5-dc013dc9c73d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:02:22.654827+07	2025-11-08 01:02:26.515199+07	\N	2025-11-07 18:02:00	00:15:00	2025-11-08 01:02:22.654827+07	2025-11-08 01:02:26.544208+07	2025-11-08 01:03:22.654827+07	f	\N
2724f6b7-12c8-48e6-961b-ce0d68dfa25b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:32:01.359673+07	2025-11-07 23:32:03.408185+07	\N	2025-11-07 16:32:00	00:15:00	2025-11-07 23:31:03.359673+07	2025-11-07 23:32:03.721297+07	2025-11-07 23:33:01.359673+07	f	\N
c3e878b9-c61b-4c46-a078-dc5fb76d41dd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:50:01.609895+07	2025-11-07 23:50:02.526257+07	\N	2025-11-07 16:50:00	00:15:00	2025-11-07 23:49:54.609895+07	2025-11-07 23:50:02.544153+07	2025-11-07 23:51:01.609895+07	f	\N
e4f0bc1e-384c-418e-9ad9-d949fdd6713a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:32:39.068027+07	2025-11-07 23:33:39.058968+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:30:39.068027+07	2025-11-07 23:33:39.089279+07	2025-11-07 23:40:39.068027+07	f	\N
b7e74736-8010-4eb4-9a5e-e5aacac711d8	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:46:41.801886+07	2025-11-08 01:46:41.813399+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:46:41.801886+07	2025-11-08 01:46:41.848427+07	2025-11-08 01:54:41.801886+07	f	\N
26582e8e-9f03-40da-8de9-b6b31848524f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:15:01.575179+07	2025-11-08 01:15:04.651314+07	\N	2025-11-07 18:15:00	00:15:00	2025-11-08 01:14:04.575179+07	2025-11-08 01:15:04.666127+07	2025-11-08 01:16:01.575179+07	f	\N
541f1524-db25-4cbd-a3d7-5a8cdee3da47	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:24:08.294985+07	2025-11-07 22:25:08.272178+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:22:08.294985+07	2025-11-07 22:25:08.312213+07	2025-11-07 22:32:08.294985+07	f	\N
bea0e353-5218-46d5-b432-19a5a34b43e6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:43:01.888027+07	2025-11-07 21:43:12.304866+07	\N	2025-11-07 14:43:00	00:15:00	2025-11-07 21:42:04.888027+07	2025-11-07 21:43:12.325565+07	2025-11-07 21:44:01.888027+07	f	\N
f6d09b70-9f82-454e-adc8-964d680c9d86	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:52:47.888071+07	2025-11-07 21:52:47.903113+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:52:47.888071+07	2025-11-07 21:52:47.936035+07	2025-11-07 22:00:47.888071+07	f	\N
6dc820ab-50fa-4e7f-a2fa-33a9879fb694	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:13:54.085344+07	2025-11-07 22:13:54.1011+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:13:54.085344+07	2025-11-07 22:13:54.136108+07	2025-11-07 22:21:54.085344+07	f	\N
8bc8d96f-7ec2-4406-95dc-98c2c6973cb3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:49:01.043737+07	2025-11-07 21:49:01.106985+07	\N	2025-11-07 14:49:00	00:15:00	2025-11-07 21:48:05.043737+07	2025-11-07 21:49:01.11829+07	2025-11-07 21:50:01.043737+07	f	\N
5aaa0dc6-c07a-4894-9cd4-63e7d5890884	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:02:01.809289+07	2025-11-07 23:02:02.916916+07	\N	2025-11-07 16:02:00	00:15:00	2025-11-07 23:01:02.809289+07	2025-11-07 23:02:02.928356+07	2025-11-07 23:03:01.809289+07	f	\N
f97878a6-d4ea-4772-9310-814a778cc8fb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:36:01.749589+07	2025-11-07 22:36:02.811027+07	\N	2025-11-07 15:36:00	00:15:00	2025-11-07 22:35:02.749589+07	2025-11-07 22:36:02.820995+07	2025-11-07 22:37:01.749589+07	f	\N
13acfb7d-4d11-4517-99a2-343e8a7fbf84	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:55:01.210373+07	2025-11-07 21:55:04.294161+07	\N	2025-11-07 14:55:00	00:15:00	2025-11-07 21:54:04.210373+07	2025-11-07 21:55:04.304421+07	2025-11-07 21:56:01.210373+07	f	\N
df5908d1-70b6-462d-9ce0-76a43a1f86f3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:15:01.292657+07	2025-11-07 22:15:02.539693+07	\N	2025-11-07 15:15:00	00:15:00	2025-11-07 22:14:02.292657+07	2025-11-07 22:15:02.564972+07	2025-11-07 22:16:01.292657+07	f	\N
4074f374-2867-4428-9b24-a9c446fd0256	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:54:47.941054+07	2025-11-07 21:55:47.92162+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:52:47.941054+07	2025-11-07 21:55:47.941514+07	2025-11-07 22:02:47.941054+07	f	\N
a3057f0f-1c5c-4c95-9dbd-214a4d658c60	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:25:01.460585+07	2025-11-07 23:25:02.315186+07	\N	2025-11-07 16:25:00	00:15:00	2025-11-07 23:24:01.460585+07	2025-11-07 23:25:02.329625+07	2025-11-07 23:26:01.460585+07	f	\N
bd8919b1-4dff-4bb3-80cd-7fca4b520438	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:56:01.301921+07	2025-11-07 21:56:04.419615+07	\N	2025-11-07 14:56:00	00:15:00	2025-11-07 21:55:04.301921+07	2025-11-07 21:56:04.445599+07	2025-11-07 21:57:01.301921+07	f	\N
9764d8f0-bf87-456e-8510-61dc122ce22e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:15:54.142524+07	2025-11-07 22:16:54.119275+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:13:54.142524+07	2025-11-07 22:16:54.155504+07	2025-11-07 22:23:54.142524+07	f	\N
0ff01e2a-d72f-4e0e-b7fc-0036611c9c5e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:40:59.512264+07	2025-11-07 23:40:59.539428+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:40:59.512264+07	2025-11-07 23:40:59.568794+07	2025-11-07 23:48:59.512264+07	f	\N
32530492-738f-411e-821c-225b6e3cd155	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:38:08.381182+07	2025-11-07 22:39:08.366738+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:36:08.381182+07	2025-11-07 22:39:08.374879+07	2025-11-07 22:46:08.381182+07	f	\N
13a90ffa-a1ca-49dd-ae7c-6fb06850d31b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:38:21.02911+07	2025-11-08 01:38:21.051336+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:38:21.02911+07	2025-11-08 01:38:21.08766+07	2025-11-08 01:46:21.02911+07	f	\N
89c77e56-dac6-4839-a10c-d7b7619a092b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:18:01.767361+07	2025-11-07 22:18:07.821361+07	\N	2025-11-07 15:18:00	00:15:00	2025-11-07 22:17:02.767361+07	2025-11-07 22:18:07.850626+07	2025-11-07 22:19:01.767361+07	f	\N
b897d333-f164-4516-b342-2939b5c49be9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:05:01.164073+07	2025-11-07 23:05:03.299187+07	\N	2025-11-07 16:05:00	00:15:00	2025-11-07 23:04:03.164073+07	2025-11-07 23:05:03.308664+07	2025-11-07 23:06:01.164073+07	f	\N
24d3da7b-4ed2-4b07-a9fc-a48177bd6359	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:41:08.377163+07	2025-11-07 22:41:08.389183+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:39:08.377163+07	2025-11-07 22:41:08.412657+07	2025-11-07 22:49:08.377163+07	f	\N
321b5449-3a93-4031-ae28-6441e7967c2b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:33:01.663491+07	2025-11-07 23:33:03.535587+07	\N	2025-11-07 16:33:00	00:15:00	2025-11-07 23:32:03.663491+07	2025-11-07 23:33:03.559971+07	2025-11-07 23:34:01.663491+07	f	\N
d8bd9c67-e77a-42ef-8e8c-59a744c7f84c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:22:01.749733+07	2025-11-07 22:22:04.848216+07	\N	2025-11-07 15:22:00	00:15:00	2025-11-07 22:21:04.749733+07	2025-11-07 22:22:04.858211+07	2025-11-07 22:23:01.749733+07	f	\N
a4f472dc-9b81-4485-9c9e-93fbd5c673b9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:03:01.538729+07	2025-11-08 01:03:13.921276+07	\N	2025-11-07 18:03:00	00:15:00	2025-11-08 01:02:26.538729+07	2025-11-08 01:03:13.941592+07	2025-11-08 01:04:01.538729+07	f	\N
b71636be-66db-4691-8d6a-158c2eb72743	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:06:01.306289+07	2025-11-07 23:06:03.436714+07	\N	2025-11-07 16:06:00	00:15:00	2025-11-07 23:05:03.306289+07	2025-11-07 23:06:03.447704+07	2025-11-07 23:07:01.306289+07	f	\N
2b9eb42d-9d6e-4c88-9d16-376313e0600c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:23:01.854984+07	2025-11-07 22:23:04.996349+07	\N	2025-11-07 15:23:00	00:15:00	2025-11-07 22:22:04.854984+07	2025-11-07 22:23:05.010287+07	2025-11-07 22:24:01.854984+07	f	\N
c9e07d39-b18a-4b12-b038-d7ffba441481	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:47:10.179632+07	2025-11-07 23:47:10.199327+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:47:10.179632+07	2025-11-07 23:47:10.237909+07	2025-11-07 23:55:10.179632+07	f	\N
0371f553-c144-4c96-966a-a8054718c9e6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:07:08.613026+07	2025-11-07 23:07:08.618591+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:05:08.613026+07	2025-11-07 23:07:08.629955+07	2025-11-07 23:15:08.613026+07	f	\N
67803f02-7192-42f6-a80f-1bbce8fed5a5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:08:01.567259+07	2025-11-07 23:08:03.738449+07	\N	2025-11-07 16:08:00	00:15:00	2025-11-07 23:07:03.567259+07	2025-11-07 23:08:03.763085+07	2025-11-07 23:09:01.567259+07	f	\N
503dbb96-f2d5-45da-8d93-3f02241a8850	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:15:42.310982+07	2025-11-08 01:15:42.324735+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:15:42.310982+07	2025-11-08 01:15:42.359377+07	2025-11-08 01:23:42.310982+07	f	\N
35582244-d542-4370-9fce-ea51d88985ca	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:51:01.540071+07	2025-11-07 23:51:05.058312+07	\N	2025-11-07 16:51:00	00:15:00	2025-11-07 23:50:02.540071+07	2025-11-07 23:51:05.203492+07	2025-11-07 23:52:01.540071+07	f	\N
885512ee-0980-444f-b0b1-30e5d97727b0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:48:01.031061+07	2025-11-08 01:48:21.655334+07	\N	2025-11-07 18:48:00	00:15:00	2025-11-08 01:47:02.031061+07	2025-11-08 01:48:21.677772+07	2025-11-08 01:49:01.031061+07	f	\N
615f2812-f565-4aef-8cd9-fc1116b7bfe9	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:17:01.523147+07	2025-11-08 01:17:04.762892+07	\N	2025-11-07 18:17:00	00:15:00	2025-11-08 01:16:02.523147+07	2025-11-08 01:17:04.783634+07	2025-11-08 01:18:01.523147+07	f	\N
901c6669-56cc-4e58-84a6-2fc6b2de96cb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:43:12.15848+07	2025-11-07 21:43:12.174869+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:43:12.15848+07	2025-11-07 21:43:12.206449+07	2025-11-07 21:51:12.15848+07	f	\N
b370a03c-9b5c-48ee-99d3-687e9838124c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:54:01.078789+07	2025-11-07 21:54:04.200433+07	\N	2025-11-07 14:54:00	00:15:00	2025-11-07 21:53:04.078789+07	2025-11-07 21:54:04.213187+07	2025-11-07 21:55:01.078789+07	f	\N
c0656c6f-8150-4951-a158-8cef313d8dfb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:40:01.2135+07	2025-11-07 22:40:03.272885+07	\N	2025-11-07 15:40:00	00:15:00	2025-11-07 22:39:03.2135+07	2025-11-07 22:40:03.290494+07	2025-11-07 22:41:01.2135+07	f	\N
31c42b2b-abed-4090-a81a-3d7f6bd21a0f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:16:01.560005+07	2025-11-07 22:16:02.663777+07	\N	2025-11-07 15:16:00	00:15:00	2025-11-07 22:15:02.560005+07	2025-11-07 22:16:02.691894+07	2025-11-07 22:17:01.560005+07	f	\N
0cc18548-02ff-4f83-b2e1-231e697d7244	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:24:49.547946+07	2025-11-07 23:24:49.57482+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:24:49.547946+07	2025-11-07 23:24:49.7592+07	2025-11-07 23:32:49.547946+07	f	\N
57855288-e929-45e0-8046-877febb0b352	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:17:01.687117+07	2025-11-07 22:17:02.758125+07	\N	2025-11-07 15:17:00	00:15:00	2025-11-07 22:16:02.687117+07	2025-11-07 22:17:02.770879+07	2025-11-07 22:18:01.687117+07	f	\N
4ba21edb-2867-4ea9-aecd-eb9761af350c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:03:01.92479+07	2025-11-07 23:03:03.038955+07	\N	2025-11-07 16:03:00	00:15:00	2025-11-07 23:02:02.92479+07	2025-11-07 23:03:03.049259+07	2025-11-07 23:04:01.92479+07	f	\N
b45019f7-e407-45b0-9dd2-e2b465912c41	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:42:01.698039+07	2025-11-07 23:42:05.443879+07	\N	2025-11-07 16:42:00	00:15:00	2025-11-07 23:41:03.698039+07	2025-11-07 23:42:05.475659+07	2025-11-07 23:43:01.698039+07	f	\N
7119ba40-e45e-4e62-bb46-1c010ce0d9fd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:03:13.790738+07	2025-11-08 01:03:13.8002+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:03:13.790738+07	2025-11-08 01:03:13.829149+07	2025-11-08 01:11:13.790738+07	f	\N
de24904e-027b-4338-bf25-34e2b339d0a7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:42:01.434377+07	2025-11-07 22:42:03.53124+07	\N	2025-11-07 15:42:00	00:15:00	2025-11-07 22:41:03.434377+07	2025-11-07 22:42:03.538721+07	2025-11-07 22:43:01.434377+07	f	\N
4dce827f-6678-45c7-be26-4cfd4061ac46	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:04:01.046862+07	2025-11-07 23:04:03.155153+07	\N	2025-11-07 16:04:00	00:15:00	2025-11-07 23:03:03.046862+07	2025-11-07 23:04:03.166628+07	2025-11-07 23:05:01.046862+07	f	\N
2c8b608f-29d5-450d-a8cc-44b26e2d78f1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:39:01.403113+07	2025-11-08 01:39:01.494011+07	\N	2025-11-07 18:39:00	00:15:00	2025-11-08 01:38:21.403113+07	2025-11-08 01:39:01.520826+07	2025-11-08 01:40:01.403113+07	f	\N
b7cd0061-acbd-4f97-a0e7-1b550a3990f5	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:43:01.536906+07	2025-11-07 22:43:03.660321+07	\N	2025-11-07 15:43:00	00:15:00	2025-11-07 22:42:03.536906+07	2025-11-07 22:43:03.669388+07	2025-11-07 22:44:01.536906+07	f	\N
717eb7cf-b23b-477c-a90a-e0f27e98d27a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:05:08.599071+07	2025-11-07 23:05:08.601407+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:03:08.599071+07	2025-11-07 23:05:08.610535+07	2025-11-07 23:13:08.599071+07	f	\N
1519e0a7-25d3-4f75-9795-fb553c29635a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:44:01.667106+07	2025-11-07 22:44:03.772372+07	\N	2025-11-07 15:44:00	00:15:00	2025-11-07 22:43:03.667106+07	2025-11-07 22:44:03.809808+07	2025-11-07 22:45:01.667106+07	f	\N
9b7e8389-f042-4b4b-b47d-b40e65579fe7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:26:01.326576+07	2025-11-07 23:26:02.519972+07	\N	2025-11-07 16:26:00	00:15:00	2025-11-07 23:25:02.326576+07	2025-11-07 23:26:02.54021+07	2025-11-07 23:27:01.326576+07	f	\N
0a1bb5c3-624c-4c37-8329-3cbfb12d550f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:43:08.415564+07	2025-11-07 22:44:08.422394+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:41:08.415564+07	2025-11-07 22:44:08.435524+07	2025-11-07 22:51:08.415564+07	f	\N
962fb975-aee2-4dcd-895e-0c2e3abf47dd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:48:01.713896+07	2025-11-07 23:48:03.888188+07	\N	2025-11-07 16:48:00	00:15:00	2025-11-07 23:47:10.713896+07	2025-11-07 23:48:03.901619+07	2025-11-07 23:49:01.713896+07	f	\N
cfb5048a-e3f2-4ded-bd1c-4a6ad84a77ab	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:07:01.44434+07	2025-11-07 23:07:03.560893+07	\N	2025-11-07 16:07:00	00:15:00	2025-11-07 23:06:03.44434+07	2025-11-07 23:07:03.56955+07	2025-11-07 23:08:01.44434+07	f	\N
66c83a27-eef4-43cb-ae62-a9cb6041e3a1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:46:08.438065+07	2025-11-07 22:47:08.445996+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:44:08.438065+07	2025-11-07 22:47:08.455347+07	2025-11-07 22:54:08.438065+07	f	\N
4fffc033-f624-4aaa-982c-f799d0cd98b6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:34:01.554846+07	2025-11-07 23:34:02.729314+07	\N	2025-11-07 16:34:00	00:15:00	2025-11-07 23:33:03.554846+07	2025-11-07 23:34:02.75061+07	2025-11-07 23:35:01.554846+07	f	\N
ffb43dda-636f-4781-8335-25ac6b5cf38c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:09:08.632788+07	2025-11-07 23:09:08.881138+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:07:08.632788+07	2025-11-07 23:09:08.915414+07	2025-11-07 23:17:08.632788+07	f	\N
0719918b-f573-4b50-a97b-e5cad77f5eda	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:05:13.833553+07	2025-11-08 01:06:13.817524+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:03:13.833553+07	2025-11-08 01:06:13.831009+07	2025-11-08 01:13:13.833553+07	f	\N
9e4a108f-df42-49a8-8c73-d4688208b58a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:50:20.814739+07	2025-11-07 23:50:20.826056+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:50:20.814739+07	2025-11-07 23:50:20.856422+07	2025-11-07 23:58:20.814739+07	f	\N
2b1c96a7-c7ab-44c2-b5d1-a5778aea8f65	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:47:26.52834+07	2025-11-08 01:47:26.538709+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:47:26.52834+07	2025-11-08 01:47:26.568516+07	2025-11-08 01:55:26.52834+07	f	\N
3bdb7a99-519d-4b0d-857e-e9ef790ea22d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:16:23.060575+07	2025-11-08 01:16:23.071641+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:16:23.060575+07	2025-11-08 01:16:23.10219+07	2025-11-08 01:24:23.060575+07	f	\N
083190f5-6c5c-4b2f-8ae4-fcec0094ec5f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:52:01.166859+07	2025-11-07 23:52:01.182895+07	\N	2025-11-07 16:52:00	00:15:00	2025-11-07 23:51:05.166859+07	2025-11-07 23:52:01.209723+07	2025-11-07 23:53:01.166859+07	f	\N
34e2eea8-5e68-47a1-ab82-e03835e9d117	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:44:01.452201+07	2025-11-07 21:44:04.692715+07	\N	2025-11-07 14:44:00	00:15:00	2025-11-07 21:43:12.452201+07	2025-11-07 21:44:04.712808+07	2025-11-07 21:45:01.452201+07	f	\N
7ffaf0d4-4317-4aba-be89-85f301437ee2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:17:26.489281+07	2025-11-07 22:17:26.52151+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:17:26.489281+07	2025-11-07 22:17:26.571982+07	2025-11-07 22:25:26.489281+07	f	\N
09ca865f-3fae-4ace-b361-f89fb2f3061b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:58:01.561551+07	2025-11-07 21:58:04.684604+07	\N	2025-11-07 14:58:00	00:15:00	2025-11-07 21:57:04.561551+07	2025-11-07 21:58:04.70734+07	2025-11-07 21:59:01.561551+07	f	\N
c9e86c94-4538-48c0-93f9-e7a6bdf7c781	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:41:01.286725+07	2025-11-07 22:41:03.416663+07	\N	2025-11-07 15:41:00	00:15:00	2025-11-07 22:40:03.286725+07	2025-11-07 22:41:03.439273+07	2025-11-07 22:42:01.286725+07	f	\N
5f123201-98c3-4c2b-a950-c7490816dd94	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:57:47.94527+07	2025-11-07 21:58:47.938252+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:55:47.94527+07	2025-11-07 21:58:47.957905+07	2025-11-07 22:05:47.94527+07	f	\N
7f1df8d3-da10-4507-8286-3fc54436b3ca	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:25:20.168483+07	2025-11-07 23:25:20.188009+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:25:20.168483+07	2025-11-07 23:25:20.229993+07	2025-11-07 23:33:20.168483+07	f	\N
7b5beae2-3fe5-42da-989a-924898cd5b6e	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:09:01.757785+07	2025-11-07 23:09:03.852038+07	\N	2025-11-07 16:09:00	00:15:00	2025-11-07 23:08:03.757785+07	2025-11-07 23:09:03.864136+07	2025-11-07 23:10:01.757785+07	f	\N
d06e257d-d366-400d-a486-56407ea7f1c1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:41:19.247208+07	2025-11-07 23:41:19.258474+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:41:19.247208+07	2025-11-07 23:41:19.283813+07	2025-11-07 23:49:19.247208+07	f	\N
e170dc4c-1cd7-440d-a95f-32f31ee35a86	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:45:01.80734+07	2025-11-07 22:45:03.879177+07	\N	2025-11-07 15:45:00	00:15:00	2025-11-07 22:44:03.80734+07	2025-11-07 22:45:03.888598+07	2025-11-07 22:46:01.80734+07	f	\N
50b1f4f6-f5dc-4acb-bc84-5989c11119c7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:00:01.839399+07	2025-11-07 22:00:04.966124+07	\N	2025-11-07 15:00:00	00:15:00	2025-11-07 21:59:04.839399+07	2025-11-07 22:00:04.989017+07	2025-11-07 22:01:01.839399+07	f	\N
b2dfa097-8a51-4022-808d-8cc3c53b22dc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:04:01.046172+07	2025-11-08 01:04:02.029195+07	\N	2025-11-07 18:04:00	00:15:00	2025-11-08 01:03:14.046172+07	2025-11-08 01:04:02.048041+07	2025-11-08 01:05:01.046172+07	f	\N
ba67ee26-2f0a-47fa-b509-b45784213464	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:01:01.986473+07	2025-11-07 22:01:05.076645+07	\N	2025-11-07 15:01:00	00:15:00	2025-11-07 22:00:04.986473+07	2025-11-07 22:01:05.088626+07	2025-11-07 22:02:01.986473+07	f	\N
da0e1440-cfba-4720-83f0-a0c71809edf8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:46:01.88571+07	2025-11-07 22:46:04.032121+07	\N	2025-11-07 15:46:00	00:15:00	2025-11-07 22:45:03.88571+07	2025-11-07 22:46:04.042111+07	2025-11-07 22:47:01.88571+07	f	\N
882dfdcd-03e8-4022-8e12-3651d9884867	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:00:47.961926+07	2025-11-07 22:01:47.960548+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:58:47.961926+07	2025-11-07 22:01:48.002883+07	2025-11-07 22:08:47.961926+07	f	\N
910857e4-27a3-43c6-82c9-6cb314cd37b2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:10:01.862373+07	2025-11-07 23:10:04.030405+07	\N	2025-11-07 16:10:00	00:15:00	2025-11-07 23:09:03.862373+07	2025-11-07 23:10:04.053099+07	2025-11-07 23:11:01.862373+07	f	\N
d3d868f9-481f-4e51-8e3a-a57726ed7cd1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:38:45.303534+07	2025-11-08 01:38:45.318097+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:38:45.303534+07	2025-11-08 01:38:45.347342+07	2025-11-08 01:46:45.303534+07	f	\N
1ba60873-843b-40a0-ab31-87e1d5381924	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:33:46.904937+07	2025-11-07 23:33:46.933443+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:33:46.904937+07	2025-11-07 23:33:46.97996+07	2025-11-07 23:41:46.904937+07	f	\N
8b6e34c7-46a1-4d9a-b91a-aa970ed53d23	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:12:01.174707+07	2025-11-07 23:12:44.1989+07	\N	2025-11-07 16:12:00	00:15:00	2025-11-07 23:11:04.174707+07	2025-11-07 23:12:44.221897+07	2025-11-07 23:13:01.174707+07	f	\N
58f7144c-ce4c-4681-878c-62a8fa758269	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:47:21.687329+07	2025-11-07 23:47:21.698501+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:47:21.687329+07	2025-11-07 23:47:21.727093+07	2025-11-07 23:55:21.687329+07	f	\N
ce475d06-324c-4b50-821a-9a82ee6d7e37	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:16:49.914527+07	2025-11-08 01:16:49.924114+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:16:49.914527+07	2025-11-08 01:16:49.950591+07	2025-11-08 01:24:49.914527+07	f	\N
eb5c0295-af57-47b7-86c5-3ccfb574ac36	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:47:54.712587+07	2025-11-08 01:47:54.722374+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:47:54.712587+07	2025-11-08 01:47:54.751198+07	2025-11-08 01:55:54.712587+07	f	\N
cdae93d8-0744-470e-b103-dc1fdafdcaf5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 00:04:25.467149+07	2025-11-08 00:05:25.454438+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 00:02:25.467149+07	2025-11-08 00:05:25.493949+07	2025-11-08 00:12:25.467149+07	f	\N
54e5a226-9156-48e2-9d25-99fe26bc7d57	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:43:20.429491+07	2025-11-07 21:43:20.441918+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:43:20.429491+07	2025-11-07 21:43:20.473805+07	2025-11-07 21:51:20.429491+07	f	\N
bcb0c54f-75ff-4a52-ae9a-a43184cdc31c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:57:01.439476+07	2025-11-07 21:57:04.553475+07	\N	2025-11-07 14:57:00	00:15:00	2025-11-07 21:56:04.439476+07	2025-11-07 21:57:04.564728+07	2025-11-07 21:58:01.439476+07	f	\N
5429326d-97bd-46cc-8bbf-2a435faadac2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:17:34.220018+07	2025-11-07 22:17:34.231054+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:17:34.220018+07	2025-11-07 22:17:34.256502+07	2025-11-07 22:25:34.220018+07	f	\N
9b2a1fc1-9493-4edf-952d-e7bc18bbf673	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:47:01.038255+07	2025-11-07 22:47:04.127859+07	\N	2025-11-07 15:47:00	00:15:00	2025-11-07 22:46:04.038255+07	2025-11-07 22:47:04.13836+07	2025-11-07 22:48:01.038255+07	f	\N
2a09a2c2-0182-4c88-8ce3-16a4a9132efd	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:11:01.048507+07	2025-11-07 23:11:04.166842+07	\N	2025-11-07 16:11:00	00:15:00	2025-11-07 23:10:04.048507+07	2025-11-07 23:11:04.176561+07	2025-11-07 23:12:01.048507+07	f	\N
180cc7a3-3803-4315-8b0e-d21a11abf537	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:25:26.25315+07	2025-11-07 23:25:26.274968+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:25:26.25315+07	2025-11-07 23:25:26.353035+07	2025-11-07 23:33:26.25315+07	f	\N
83b19c39-325a-427b-80ec-6e1aed2d5223	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:41:25.133959+07	2025-11-07 23:41:25.14659+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:41:25.133959+07	2025-11-07 23:41:25.175746+07	2025-11-07 23:49:25.133959+07	f	\N
647e20f2-4361-4ef0-aed8-f3d4bbe43346	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:49:01.256841+07	2025-11-07 22:49:04.38026+07	\N	2025-11-07 15:49:00	00:15:00	2025-11-07 22:48:04.256841+07	2025-11-07 22:49:04.391052+07	2025-11-07 22:50:01.256841+07	f	\N
6fc4fcf0-5703-4033-9087-fe7822db994b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:49:08.45788+07	2025-11-07 22:49:08.461655+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:47:08.45788+07	2025-11-07 22:49:08.482539+07	2025-11-07 22:57:08.45788+07	f	\N
8dc2525a-9ad4-4cc3-87f0-31bfd1b20cbf	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:40:01.513095+07	2025-11-08 01:40:35.943303+07	\N	2025-11-07 18:40:00	00:15:00	2025-11-08 01:39:01.513095+07	2025-11-08 01:40:35.96156+07	2025-11-08 01:41:01.513095+07	f	\N
38e0aecc-a773-4d70-a272-26b45ec43966	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:34:02.576743+07	2025-11-07 23:34:02.590251+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:34:02.576743+07	2025-11-07 23:34:02.622514+07	2025-11-07 23:42:02.576743+07	f	\N
cec819dc-e395-4f8e-b754-5669b8c9bc62	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:05:01.043195+07	2025-11-08 01:05:02.132543+07	\N	2025-11-07 18:05:00	00:15:00	2025-11-08 01:04:02.043195+07	2025-11-08 01:05:02.145842+07	2025-11-08 01:06:01.043195+07	f	\N
55eef42a-a26d-417d-8514-7af1e46e0521	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:47:31.798481+07	2025-11-07 23:47:31.809742+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:47:31.798481+07	2025-11-07 23:47:31.8412+07	2025-11-07 23:55:31.798481+07	f	\N
4ed30d96-9754-480f-97ca-aceb7c80a86f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:08:01.380617+07	2025-11-08 01:08:02.496432+07	\N	2025-11-07 18:08:00	00:15:00	2025-11-08 01:07:02.380617+07	2025-11-08 01:08:02.508141+07	2025-11-08 01:09:01.380617+07	f	\N
e1ae2c4f-4315-452d-bf51-fa011cf4a889	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 00:02:25.418391+07	2025-11-08 00:02:25.429695+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 00:02:25.418391+07	2025-11-08 00:02:25.463752+07	2025-11-08 00:10:25.418391+07	f	\N
0c691693-1fae-480a-8db8-f168061a2ba0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:48:21.502846+07	2025-11-08 01:48:21.513525+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:48:21.502846+07	2025-11-08 01:48:21.540992+07	2025-11-08 01:56:21.502846+07	f	\N
34bae1cb-1616-4f90-8440-52b5518973c1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:10:01.598609+07	2025-11-08 01:10:14.187537+07	\N	2025-11-07 18:10:00	00:15:00	2025-11-08 01:09:02.598609+07	2025-11-08 01:10:14.206537+07	2025-11-08 01:11:01.598609+07	f	\N
34a50e80-e4d1-422f-a22d-17efce60165b	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:17:04.607571+07	2025-11-08 01:17:04.618349+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:17:04.607571+07	2025-11-08 01:17:04.646998+07	2025-11-08 01:25:04.607571+07	f	\N
44f1e3b0-80ac-4bb9-966e-ec42e0166979	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:19:04.651824+07	2025-11-08 01:20:04.652289+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:17:04.651824+07	2025-11-08 01:20:04.67277+07	2025-11-08 01:27:04.651824+07	f	\N
122d75a2-bde5-448a-be56-3f4f2ab1cadb	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:50:01.387831+07	2025-11-07 22:50:04.466332+07	\N	2025-11-07 15:50:00	00:15:00	2025-11-07 22:49:04.387831+07	2025-11-07 22:50:04.5073+07	2025-11-07 22:51:01.387831+07	f	\N
8fa7273b-5a81-4a97-a8e4-65d2b3d79f54	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:45:01.708491+07	2025-11-07 21:45:04.339752+07	\N	2025-11-07 14:45:00	00:15:00	2025-11-07 21:44:04.708491+07	2025-11-07 21:45:04.356439+07	2025-11-07 21:46:01.708491+07	f	\N
78df215c-a943-41cf-bbd9-0bc6ae9b9080	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:59:01.702436+07	2025-11-07 21:59:04.823688+07	\N	2025-11-07 14:59:00	00:15:00	2025-11-07 21:58:04.702436+07	2025-11-07 21:59:04.842216+07	2025-11-07 22:00:01.702436+07	f	\N
b11f84a3-794d-42e0-8d54-6f77f0d57963	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:17:41.328007+07	2025-11-07 22:17:41.338576+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:17:41.328007+07	2025-11-07 22:17:41.367062+07	2025-11-07 22:25:41.328007+07	f	\N
975e49ad-38ca-47ce-929e-b24ebfe68773	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:48:01.134206+07	2025-11-07 22:48:04.25146+07	\N	2025-11-07 15:48:00	00:15:00	2025-11-07 22:47:04.134206+07	2025-11-07 22:48:04.258915+07	2025-11-07 22:49:01.134206+07	f	\N
a7313e06-94d9-46f3-9ded-7f558448cbf1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 00:02:25.674793+07	2025-11-08 00:02:29.571396+07	\N	2025-11-07 17:02:00	00:15:00	2025-11-08 00:02:25.674793+07	2025-11-08 00:02:29.600407+07	2025-11-08 00:03:25.674793+07	f	\N
8f9f196f-a95c-4465-8600-168195d91981	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:02:01.086048+07	2025-11-07 22:02:01.156317+07	\N	2025-11-07 15:02:00	00:15:00	2025-11-07 22:01:05.086048+07	2025-11-07 22:02:01.179114+07	2025-11-07 22:03:01.086048+07	f	\N
3856efe6-b4e7-4901-a1dd-274e19dad8f3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:27:01.536523+07	2025-11-07 23:27:02.116037+07	\N	2025-11-07 16:27:00	00:15:00	2025-11-07 23:26:02.536523+07	2025-11-07 23:27:02.131039+07	2025-11-07 23:28:01.536523+07	f	\N
e6d8d495-76c2-46a9-9b33-8dad981be21d	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:41:34.568193+07	2025-11-07 23:41:34.595538+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:41:34.568193+07	2025-11-07 23:41:34.643564+07	2025-11-07 23:49:34.568193+07	f	\N
9cbef1cd-af06-4557-a862-c954d7a28285	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:04:01.302523+07	2025-11-07 22:04:01.377594+07	\N	2025-11-07 15:04:00	00:15:00	2025-11-07 22:03:01.302523+07	2025-11-07 22:04:01.390641+07	2025-11-07 22:05:01.302523+07	f	\N
3ec29ce1-14c5-4887-bac2-9422a9cf2c4a	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:51:08.485046+07	2025-11-07 22:52:08.485682+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:49:08.485046+07	2025-11-07 22:52:08.526734+07	2025-11-07 22:59:08.485046+07	f	\N
0628119b-933f-4319-9a85-e71b82917de5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:03:48.009071+07	2025-11-07 22:04:47.978851+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:01:48.009071+07	2025-11-07 22:04:47.994496+07	2025-11-07 22:11:48.009071+07	f	\N
5a2240c4-cc24-4852-ba40-ee7ea51b33e2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:35:01.865244+07	2025-11-07 23:35:02.69513+07	\N	2025-11-07 16:35:00	00:15:00	2025-11-07 23:34:02.865244+07	2025-11-07 23:35:02.709357+07	2025-11-07 23:36:01.865244+07	f	\N
587b4da1-6187-4945-be07-1e7bb08a40ce	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:06:47.99753+07	2025-11-07 22:06:48.012951+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:04:47.99753+07	2025-11-07 22:06:48.038009+07	2025-11-07 22:14:47.99753+07	f	\N
c4a478ac-9594-4f8e-a56a-4b7b21b0b8c2	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:12:44.035505+07	2025-11-07 23:12:44.053868+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:12:44.035505+07	2025-11-07 23:12:44.08572+07	2025-11-07 23:20:44.035505+07	f	\N
6ab683ce-7e23-42a0-b73e-2039a5a07f2a	area-xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762540741857-BangToaDo_2025.xls", "userId": 3, "districtId": "b246ae91-2e2e-4f29-8a6b-29be23b6e663", "provinceId": "f851f9a1-330b-4d29-98ae-f4092e7e7f70", "originalname": "BangToaDo_2025.xls"}	completed	0	0	0	f	2025-11-08 01:39:01.868679+07	2025-11-08 01:39:03.740909+07	\N	\N	00:15:00	2025-11-08 01:39:01.868679+07	2025-11-08 01:39:04.095998+07	2025-11-22 01:39:01.868679+07	f	{"created": 0, "skipped": 0, "totalRows": 1, "duplicates": 0, "skippedRows": [{"x": 2318587, "y": 428692, "row": 2, "name": "Luồng vào cảng Cái Lân tại cầu Bãi Cháy", "reason": "conversion_failed"}], "notConverted": 1}
33f4d3cb-15c0-4fef-8010-962b5f730a55	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:08:01.746381+07	2025-11-07 22:08:01.888024+07	\N	2025-11-07 15:08:00	00:15:00	2025-11-07 22:07:01.746381+07	2025-11-07 22:08:01.92793+07	2025-11-07 22:09:01.746381+07	f	\N
36c0945b-5edc-4f46-a377-732a0ca3fa71	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:14:44.090828+07	2025-11-07 23:15:44.064579+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:12:44.090828+07	2025-11-07 23:15:44.084386+07	2025-11-07 23:22:44.090828+07	f	\N
cd7a768c-0935-46df-8a90-57723e02f7bb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:08:48.044092+07	2025-11-07 22:09:48.034113+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:06:48.044092+07	2025-11-07 22:09:48.055251+07	2025-11-07 22:16:48.044092+07	f	\N
fbc46de1-eebd-4d75-90fa-f169ffceabdc	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:47:44.61601+07	2025-11-07 23:47:44.625382+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:47:44.61601+07	2025-11-07 23:47:44.652422+07	2025-11-07 23:55:44.61601+07	f	\N
56babb4c-cb2c-4c9d-abaa-222abb764d28	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:06:01.141479+07	2025-11-08 01:06:02.253743+07	\N	2025-11-07 18:06:00	00:15:00	2025-11-08 01:05:02.141479+07	2025-11-08 01:06:02.265594+07	2025-11-08 01:07:01.141479+07	f	\N
dda021dd-6cad-48b1-9315-8e4b3e6da6c7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:49:01.784267+07	2025-11-08 01:49:05.75464+07	\N	2025-11-07 18:49:00	00:15:00	2025-11-08 01:48:21.784267+07	2025-11-08 01:49:05.767805+07	2025-11-08 01:50:01.784267+07	f	\N
1b41ab52-bbe5-456f-9539-eb4088813f60	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:07:01.26173+07	2025-11-08 01:07:02.369029+07	\N	2025-11-07 18:07:00	00:15:00	2025-11-08 01:06:02.26173+07	2025-11-08 01:07:02.383535+07	2025-11-08 01:08:01.26173+07	f	\N
9e21a7a2-a23f-4296-8faa-0a59580f314c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:09:01.505029+07	2025-11-08 01:09:02.586204+07	\N	2025-11-07 18:09:00	00:15:00	2025-11-08 01:08:02.505029+07	2025-11-08 01:09:02.602607+07	2025-11-08 01:10:01.505029+07	f	\N
daea4bf3-c4a5-49ac-8e20-09b9f2cdce30	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:18:01.897772+07	2025-11-08 01:18:04.879778+07	\N	2025-11-07 18:18:00	00:15:00	2025-11-08 01:17:04.897772+07	2025-11-08 01:18:04.902536+07	2025-11-08 01:19:01.897772+07	f	\N
267184d4-267e-4db8-8f1b-1c54f0d67e6c	xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762283595084-Tong hop NB.2021-2025.IN.xlsx", "userId": 5, "template": "excel2", "modelName": "cobia_xgboost", "originalname": "Tong hop NB.2021-2025.IN.xlsx"}	retry	3	1	60000	f	2025-11-08 14:17:24.887839+07	2025-11-07 21:37:21.374149+07	\N	\N	00:15:00	2025-11-05 02:13:15.096792+07	\N	2025-11-19 02:13:15.096792+07	f	{"data": {"error": "Failed at row 1/32 (area: Luồng vào cảng Cái Lân tại cầu Bãi Cháy): getaddrinfo ENOTFOUND flask_backend"}, "name": "Error", "stack": "Error: Failed at row 1/32 (area: Luồng vào cảng Cái Lân tại cầu Bãi Cháy): getaddrinfo ENOTFOUND flask_backend\\n    at Object.json (D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\src\\\\workers\\\\importBoss.js:40:35)\\n    at exports.createBatchPredictionFromExcel2 (D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\src\\\\controllers\\\\predictionController.js:843:28)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)", "message": "Failed at row 1/32 (area: Luồng vào cảng Cái Lân tại cầu Bãi Cháy): getaddrinfo ENOTFOUND flask_backend", "statusCode": 500}
8401a568-59c5-4796-bdcf-3019b3f6d038	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:25:04.701192+07	2025-11-08 01:26:04.689365+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:23:04.701192+07	2025-11-08 01:26:04.712072+07	2025-11-08 01:33:04.701192+07	f	\N
8cff70ac-50d5-4918-aa2b-b086ca36bdc1	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:44:15.98966+07	2025-11-07 21:44:16.004762+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:44:15.98966+07	2025-11-07 21:44:16.047969+07	2025-11-07 21:52:15.98966+07	f	\N
e763e36f-3caf-4b50-a031-83a8bb26d48c	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:03:01.175138+07	2025-11-07 22:03:01.281158+07	\N	2025-11-07 15:03:00	00:15:00	2025-11-07 22:02:01.175138+07	2025-11-07 22:03:01.30833+07	2025-11-07 22:04:01.175138+07	f	\N
7a43df4c-1210-43e5-867b-64708dcbe56c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:17:50.075276+07	2025-11-07 22:17:50.087601+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:17:50.075276+07	2025-11-07 22:17:50.113736+07	2025-11-07 22:25:50.075276+07	f	\N
d3a452fb-d6e3-4cd3-b0a3-53fef9d4c35c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:26:50.635721+07	2025-11-07 23:26:50.659327+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:26:50.635721+07	2025-11-07 23:26:50.6992+07	2025-11-07 23:34:50.635721+07	f	\N
2e4c1c38-16aa-4a93-8877-32b3eaf51db6	xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762283967897-Tong hop NB.2021-2025.IN.xlsx", "userId": 5, "template": "excel2", "modelName": "cobia_xgboost", "originalname": "Tong hop NB.2021-2025.IN.xlsx"}	retry	3	1	60000	f	2025-11-08 14:17:24.916999+07	2025-11-07 21:37:24.904812+07	\N	\N	00:15:00	2025-11-05 02:19:27.91115+07	\N	2025-11-19 02:19:27.91115+07	f	{"name": "Error", "stack": "Error: file_not_found\\n    at D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\src\\\\workers\\\\importBoss.js:172:31\\n    at pMap.concurrency (D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\node_modules\\\\pg-boss\\\\src\\\\manager.js:234:32)\\n    at D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\node_modules\\\\p-map\\\\index.js:57:28\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)", "message": "file_not_found"}
c79200ca-9dee-4a3a-b860-2f34e5b1aff6	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:13:01.355019+07	2025-11-07 23:13:04.220774+07	\N	2025-11-07 16:13:00	00:15:00	2025-11-07 23:12:44.355019+07	2025-11-07 23:13:04.239104+07	2025-11-07 23:14:01.355019+07	f	\N
29bcfece-1328-48e2-97e8-6d2bdd1f6a28	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:05:01.386681+07	2025-11-07 22:05:01.509329+07	\N	2025-11-07 15:05:00	00:15:00	2025-11-07 22:04:01.386681+07	2025-11-07 22:05:01.518916+07	2025-11-07 22:06:01.386681+07	f	\N
fb1fc6a0-108a-42fd-ad5c-21a49698aba5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:41:49.396047+07	2025-11-07 23:41:49.507173+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:41:49.396047+07	2025-11-07 23:41:49.657064+07	2025-11-07 23:49:49.396047+07	f	\N
a5190c4c-7d87-479f-a9b0-83ebf6a96425	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:14:01.235533+07	2025-11-07 23:14:04.317037+07	\N	2025-11-07 16:14:00	00:15:00	2025-11-07 23:13:04.235533+07	2025-11-07 23:14:04.366584+07	2025-11-07 23:15:01.235533+07	f	\N
cf00121c-aac8-4485-bfee-285066ca573a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:06:01.515977+07	2025-11-07 22:06:01.616415+07	\N	2025-11-07 15:06:00	00:15:00	2025-11-07 22:05:01.515977+07	2025-11-07 22:06:01.627431+07	2025-11-07 22:07:01.515977+07	f	\N
1037d2c2-a1cc-4656-98eb-11ea2e05be74	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:09:22.166031+07	2025-11-08 01:09:22.180525+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:09:22.166031+07	2025-11-08 01:09:22.211245+07	2025-11-08 01:17:22.166031+07	f	\N
4874550b-dea9-45ea-9c5a-5a28222482ec	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:07:01.624854+07	2025-11-07 22:07:01.729236+07	\N	2025-11-07 15:07:00	00:15:00	2025-11-07 22:06:01.624854+07	2025-11-07 22:07:01.749602+07	2025-11-07 22:08:01.624854+07	f	\N
f566f4f7-c299-4c13-a086-56284503a84f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:34:38.511408+07	2025-11-07 23:34:38.523254+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:34:38.511408+07	2025-11-07 23:34:38.551232+07	2025-11-07 23:42:38.511408+07	f	\N
3f2e5339-efe0-4dae-beaa-2fff4944a9fb	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:47:50.26453+07	2025-11-07 23:47:50.2739+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:47:50.26453+07	2025-11-07 23:47:50.307688+07	2025-11-07 23:55:50.26453+07	f	\N
bb6bd417-bc10-4367-b83c-74caf2a4b5fd	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:40:35.803167+07	2025-11-08 01:40:35.813065+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:40:35.803167+07	2025-11-08 01:40:35.845022+07	2025-11-08 01:48:35.803167+07	f	\N
04e478a2-6840-4b00-99f6-ca87a8d249e1	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:36:01.706484+07	2025-11-07 23:36:02.805468+07	\N	2025-11-07 16:36:00	00:15:00	2025-11-07 23:35:02.706484+07	2025-11-07 23:36:02.868059+07	2025-11-07 23:37:01.706484+07	f	\N
623e55e9-6f5e-43b9-9434-37e768eed1ce	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:19:01.896121+07	2025-11-08 01:19:05.002199+07	\N	2025-11-07 18:19:00	00:15:00	2025-11-08 01:18:04.896121+07	2025-11-08 01:19:05.013808+07	2025-11-08 01:20:01.896121+07	f	\N
4fc3540c-3e5a-42e9-8fe4-cc897c3712f0	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:36:38.555881+07	2025-11-07 23:37:38.549789+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:34:38.555881+07	2025-11-07 23:37:38.585581+07	2025-11-07 23:44:38.555881+07	f	\N
c36f6a56-aaf4-4b22-85d3-1ff085f42926	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:21:01.099962+07	2025-11-08 01:21:01.188561+07	\N	2025-11-07 18:21:00	00:15:00	2025-11-08 01:20:05.099962+07	2025-11-08 01:21:01.204544+07	2025-11-08 01:22:01.099962+07	f	\N
175a7cdc-c78c-45c8-be1f-f90015ff14a0	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:38:01.965795+07	2025-11-07 23:38:03.05902+07	\N	2025-11-07 16:38:00	00:15:00	2025-11-07 23:37:02.965795+07	2025-11-07 23:38:03.075699+07	2025-11-07 23:39:01.965795+07	f	\N
ab92a952-7c7c-4eb8-92ec-e9d5f2ac741b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:39:01.073185+07	2025-11-07 23:39:08.982615+07	\N	2025-11-07 16:39:00	00:15:00	2025-11-07 23:38:03.073185+07	2025-11-07 23:39:09.013554+07	2025-11-07 23:40:01.073185+07	f	\N
ab5b2664-820a-4b4d-899d-d948556946d7	area-xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762540852475-BangToaDo_2025.xls", "userId": 3, "districtId": "b246ae91-2e2e-4f29-8a6b-29be23b6e663", "provinceId": "f851f9a1-330b-4d29-98ae-f4092e7e7f70", "originalname": "BangToaDo_2025.xls"}	failed	0	0	0	f	2025-11-08 01:40:52.484286+07	2025-11-08 01:40:54.251515+07	\N	\N	00:15:00	2025-11-08 01:40:52.484286+07	2025-11-08 01:40:54.531144+07	2025-11-22 01:40:52.484286+07	f	{"name": "TypeError", "stack": "TypeError: jobLogger.debug is not a function\\n    at convertVN2000ToWGS84 (D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\src\\\\workers\\\\importBoss.js:73:27)\\n    at D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\src\\\\workers\\\\importBoss.js:341:36\\n    at process.processTicksAndRejections (node:internal/process/task_queues:95:5)\\n    at async resolveWithinSeconds (D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\node_modules\\\\pg-boss\\\\src\\\\manager.js:35:14)\\n    at async D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\node_modules\\\\p-map\\\\index.js:57:22", "message": "jobLogger.debug is not a function"}
59a33a03-6b6c-4647-b72f-ff81f9549308	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:24:01.671695+07	2025-11-08 01:24:01.774558+07	\N	2025-11-07 18:24:00	00:15:00	2025-11-08 01:23:01.671695+07	2025-11-08 01:24:01.789947+07	2025-11-08 01:25:01.671695+07	f	\N
d9a9563e-8bdf-423e-9ec2-ddc6517df501	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:50:01.764214+07	2025-11-08 01:50:03.987364+07	\N	2025-11-07 18:50:00	00:15:00	2025-11-08 01:49:05.764214+07	2025-11-08 01:50:04.002217+07	2025-11-08 01:51:01.764214+07	f	\N
4936942e-d03a-4686-b2b5-83be1f7cbfc5	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:44:29.969098+07	2025-11-07 21:44:29.979408+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:44:29.969098+07	2025-11-07 21:44:30.005802+07	2025-11-07 21:52:29.969098+07	f	\N
087d93d1-41be-405f-8b51-d3460450447d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:09:01.924386+07	2025-11-07 22:09:01.975588+07	\N	2025-11-07 15:09:00	00:15:00	2025-11-07 22:08:01.924386+07	2025-11-07 22:09:01.995536+07	2025-11-07 22:10:01.924386+07	f	\N
7562ec6b-ad50-44d1-aebe-73ad66f3c9de	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:17:56.508771+07	2025-11-07 22:17:56.518735+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:17:56.508771+07	2025-11-07 22:17:56.541907+07	2025-11-07 22:25:56.508771+07	f	\N
9017269a-9ba1-43c7-80ca-1df739c55ea4	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:15:01.360392+07	2025-11-07 23:15:04.424483+07	\N	2025-11-07 16:15:00	00:15:00	2025-11-07 23:14:04.360392+07	2025-11-07 23:15:04.45786+07	2025-11-07 23:16:01.360392+07	f	\N
b8e05556-75bc-4656-8762-c1e2361b2e66	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:26:57.937634+07	2025-11-07 23:26:57.948755+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:26:57.937634+07	2025-11-07 23:26:57.975696+07	2025-11-07 23:34:57.937634+07	f	\N
bc349552-d6fc-4ce0-88a9-3b5d432a3aa6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:42:01.140485+07	2025-11-07 23:42:01.182813+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:42:01.140485+07	2025-11-07 23:42:01.291027+07	2025-11-07 23:50:01.140485+07	f	\N
4b58d725-841b-4caa-a8a7-f76c738e860c	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:09:40.833066+07	2025-11-08 01:09:40.846177+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:09:40.833066+07	2025-11-08 01:09:40.878994+07	2025-11-08 01:17:40.833066+07	f	\N
7dd94d4b-bead-489d-8d24-2bf184199012	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:28:01.127784+07	2025-11-07 23:28:02.223743+07	\N	2025-11-07 16:28:00	00:15:00	2025-11-07 23:27:02.127784+07	2025-11-07 23:28:02.242471+07	2025-11-07 23:29:01.127784+07	f	\N
e42b18bf-b561-48d9-9434-001983c5de42	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:41:01.083351+07	2025-11-08 01:41:03.982639+07	\N	2025-11-07 18:41:00	00:15:00	2025-11-08 01:40:36.083351+07	2025-11-08 01:41:03.997574+07	2025-11-08 01:42:01.083351+07	f	\N
1eb11ea2-4d32-4091-a729-b1ffb991cabe	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:47:55.715845+07	2025-11-07 23:47:55.724757+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:47:55.715845+07	2025-11-07 23:47:55.753126+07	2025-11-07 23:55:55.715845+07	f	\N
76753220-a5ec-4f71-b849-398ed89b7a16	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:37:01.856066+07	2025-11-07 23:37:02.940151+07	\N	2025-11-07 16:37:00	00:15:00	2025-11-07 23:36:02.856066+07	2025-11-07 23:37:02.97316+07	2025-11-07 23:38:01.856066+07	f	\N
c8faf16c-7801-4fb7-9bb0-cc89e83df449	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:42:01.994786+07	2025-11-08 01:42:03.780581+07	\N	2025-11-07 18:42:00	00:15:00	2025-11-08 01:41:03.994786+07	2025-11-08 01:42:03.79681+07	2025-11-08 01:43:01.994786+07	f	\N
80b119fb-97a1-4815-bb63-c8476d9b37a7	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:20:01.917882+07	2025-11-08 01:20:05.091946+07	\N	2025-11-07 18:20:00	00:15:00	2025-11-08 01:19:04.917882+07	2025-11-08 01:20:05.102995+07	2025-11-08 01:21:01.917882+07	f	\N
39b09e70-0f99-4ab7-9ade-38d251a1647d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:49:01.898576+07	2025-11-07 23:49:54.498601+07	\N	2025-11-07 16:49:00	00:15:00	2025-11-07 23:48:03.898576+07	2025-11-07 23:49:54.52084+07	2025-11-07 23:50:01.898576+07	f	\N
047691e4-eb1b-4211-bc08-adde539376c3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:23:01.576534+07	2025-11-08 01:23:01.661903+07	\N	2025-11-07 18:23:00	00:15:00	2025-11-08 01:22:01.576534+07	2025-11-08 01:23:01.675157+07	2025-11-08 01:24:01.576534+07	f	\N
005bf88a-758f-4476-a6fe-8744e2b64c97	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:49:31.266196+07	2025-11-08 01:49:31.278524+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:49:31.266196+07	2025-11-08 01:49:31.313643+07	2025-11-08 01:57:31.266196+07	f	\N
dc897e9e-1d42-4b8e-be4e-e0c03b20191f	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:22:04.676876+07	2025-11-08 01:23:04.673558+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:20:04.676876+07	2025-11-08 01:23:04.698114+07	2025-11-08 01:30:04.676876+07	f	\N
ae9f1490-b9b5-4f4c-8da9-790da0b69c98	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:45:00.165013+07	2025-11-07 21:45:00.177866+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:45:00.165013+07	2025-11-07 21:45:00.215311+07	2025-11-07 21:53:00.165013+07	f	\N
07e03d83-e5c9-4102-8a6e-738e1ad2f6a8	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:10:01.990448+07	2025-11-07 22:10:02.10346+07	\N	2025-11-07 15:10:00	00:15:00	2025-11-07 22:09:01.990448+07	2025-11-07 22:10:02.120107+07	2025-11-07 22:11:01.990448+07	f	\N
5fed9038-1b0a-460f-805c-d89d446a8838	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 22:18:07.653229+07	2025-11-07 22:18:07.665405+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 22:18:07.653229+07	2025-11-07 22:18:07.700368+07	2025-11-07 22:26:07.653229+07	f	\N
75fc884c-420a-4e71-8f6e-0a5d30b7c5a2	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:29:01.238721+07	2025-11-07 23:29:02.28555+07	\N	2025-11-07 16:29:00	00:15:00	2025-11-07 23:28:02.238721+07	2025-11-07 23:29:02.30396+07	2025-11-07 23:30:01.238721+07	f	\N
9de9e237-a4a9-4443-bf09-44e7937279f3	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:43:01.605118+07	2025-11-07 23:43:01.609796+07	\N	2025-11-07 16:43:00	00:15:00	2025-11-07 23:42:01.605118+07	2025-11-07 23:43:01.671322+07	2025-11-07 23:44:01.605118+07	f	\N
db7479c2-311c-40ba-80a2-10083872f753	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:16:01.450894+07	2025-11-07 23:16:04.542143+07	\N	2025-11-07 16:16:00	00:15:00	2025-11-07 23:15:04.450894+07	2025-11-07 23:16:04.553233+07	2025-11-07 23:17:01.450894+07	f	\N
08dd5d26-71d7-45c5-8f3d-74b750cba4e6	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:10:13.895432+07	2025-11-08 01:10:13.907407+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:10:13.895432+07	2025-11-08 01:10:13.940475+07	2025-11-08 01:18:13.895432+07	f	\N
5691c983-875e-4104-bf28-bc446cf7557f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:17:01.550697+07	2025-11-07 23:17:04.656351+07	\N	2025-11-07 16:17:00	00:15:00	2025-11-07 23:16:04.550697+07	2025-11-07 23:17:04.671645+07	2025-11-07 23:18:01.550697+07	f	\N
4b3a8ca8-f309-4433-8dd3-3fd8da4d7dc3	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:39:08.80835+07	2025-11-07 23:39:08.826792+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:39:08.80835+07	2025-11-07 23:39:08.856712+07	2025-11-07 23:47:08.80835+07	f	\N
a782614e-b245-4b13-b004-be79f00bdd89	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:17:44.087573+07	2025-11-07 23:17:44.088732+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:15:44.087573+07	2025-11-07 23:17:44.112672+07	2025-11-07 23:25:44.087573+07	f	\N
9502e821-9895-476e-833c-f5cc98039dd7	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:41:27.564824+07	2025-11-08 01:41:27.575799+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:41:27.564824+07	2025-11-08 01:41:27.602687+07	2025-11-08 01:49:27.564824+07	f	\N
2e3c6e6f-4ca0-4bbf-9825-a5e1fc3f5d09	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:45:01.729264+07	2025-11-07 23:45:03.835288+07	\N	2025-11-07 16:45:00	00:15:00	2025-11-07 23:44:01.729264+07	2025-11-07 23:45:03.854214+07	2025-11-07 23:46:01.729264+07	f	\N
bb003e0b-7aa8-49f8-b1aa-981883896872	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:48:18.258883+07	2025-11-07 23:48:18.269193+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:48:18.258883+07	2025-11-07 23:48:18.296322+07	2025-11-07 23:56:18.258883+07	f	\N
4ecf3f14-40cf-47f3-b404-4e4c0c573b8a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:22:01.199278+07	2025-11-08 01:22:01.551502+07	\N	2025-11-07 18:22:00	00:15:00	2025-11-08 01:21:01.199278+07	2025-11-08 01:22:01.580668+07	2025-11-08 01:23:01.199278+07	f	\N
72fe2710-6693-4b5b-bf18-e598f9e8674b	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:43:01.793357+07	2025-11-08 01:43:01.88935+07	\N	2025-11-07 18:43:00	00:15:00	2025-11-08 01:42:03.793357+07	2025-11-08 01:43:01.906272+07	2025-11-08 01:44:01.793357+07	f	\N
e0731bc6-444f-40b1-b9b9-e635d9a96b3a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:25:01.787387+07	2025-11-08 01:25:01.910217+07	\N	2025-11-07 18:25:00	00:15:00	2025-11-08 01:24:01.787387+07	2025-11-08 01:25:01.945643+07	2025-11-08 01:26:01.787387+07	f	\N
446c7c31-eb5d-4a56-bcea-019e53730adf	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-08 01:49:39.790858+07	2025-11-08 01:49:39.799649+07	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:49:39.790858+07	2025-11-08 01:49:39.827428+07	2025-11-08 01:57:39.790858+07	f	\N
d2822829-6384-4e40-84bf-32df196963de	__pgboss__maintenance	0	\N	created	0	0	0	f	2025-11-08 01:51:39.832429+07	\N	__pgboss__maintenance	\N	00:15:00	2025-11-08 01:49:39.832429+07	\N	2025-11-08 01:59:39.832429+07	f	\N
b28ba068-5ea8-4971-844c-32c6d89b6cfb	__pgboss__cron	0	\N	created	2	0	0	f	2025-11-08 01:51:01.999637+07	\N	\N	2025-11-07 18:51:00	00:15:00	2025-11-08 01:50:03.999637+07	\N	2025-11-08 01:52:01.999637+07	f	\N
0d4a97b8-f6c7-4e7e-8897-11fb5bb46e3f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:39:01.905012+07	2025-11-07 21:39:05.442947+07	\N	2025-11-07 14:39:00	00:15:00	2025-11-07 21:38:04.905012+07	2025-11-07 21:39:05.458704+07	2025-11-07 21:40:01.905012+07	f	\N
21ad7153-a055-498d-947a-ee240cfec92a	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:40:01.194688+07	2025-11-07 23:40:02.688647+07	\N	2025-11-07 16:40:00	00:15:00	2025-11-07 23:39:09.194688+07	2025-11-07 23:40:02.714713+07	2025-11-07 23:41:01.194688+07	f	\N
fe129b0e-d519-412b-92df-5cf9cd3e4298	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:18:01.666731+07	2025-11-07 23:18:04.761707+07	\N	2025-11-07 16:18:00	00:15:00	2025-11-07 23:17:04.666731+07	2025-11-07 23:18:04.773211+07	2025-11-07 23:19:01.666731+07	f	\N
52e25330-7f0c-4109-8580-d31e42944acc	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:46:01.537186+07	2025-11-07 21:46:04.781333+07	\N	2025-11-07 14:46:00	00:15:00	2025-11-07 21:45:00.537186+07	2025-11-07 21:46:04.809253+07	2025-11-07 21:47:01.537186+07	f	\N
7fab2c05-8029-4ef3-9e14-192eaa0bd82d	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 22:19:01.99727+07	2025-11-07 22:19:04.081217+07	\N	2025-11-07 15:19:00	00:15:00	2025-11-07 22:18:07.99727+07	2025-11-07 22:19:04.098464+07	2025-11-07 22:20:01.99727+07	f	\N
91300f78-d9cb-440c-a17e-d1b482280036	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:28:34.054598+07	2025-11-07 23:28:34.071353+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:28:34.054598+07	2025-11-07 23:28:34.102331+07	2025-11-07 23:36:34.054598+07	f	\N
01f5409d-3158-4c06-b32e-8c68ad5d8255	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:26:01.937948+07	2025-11-08 01:26:02.078882+07	\N	2025-11-07 18:26:00	00:15:00	2025-11-08 01:25:01.937948+07	2025-11-08 01:26:02.094504+07	2025-11-08 01:27:01.937948+07	f	\N
059f96d4-63f1-4238-b967-9ec32d47d87f	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-08 01:11:01.418505+07	2025-11-08 01:11:02.280109+07	\N	2025-11-07 18:11:00	00:15:00	2025-11-08 01:10:14.418505+07	2025-11-08 01:11:02.298695+07	2025-11-08 01:12:01.418505+07	f	\N
2e1c8a33-4378-4194-915e-b1f2c2743909	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 23:44:01.663487+07	2025-11-07 23:44:01.72528+07	\N	2025-11-07 16:44:00	00:15:00	2025-11-07 23:43:01.663487+07	2025-11-07 23:44:01.754829+07	2025-11-07 23:45:01.663487+07	f	\N
faa66e97-c5e1-4d2b-8b5f-04c60226f63e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 23:48:32.368917+07	2025-11-07 23:48:32.387368+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 23:48:32.368917+07	2025-11-07 23:48:32.428508+07	2025-11-07 23:56:32.368917+07	f	\N
ddb34e7f-1696-490f-abdb-094077562de4	area-xlsx-import	0	{"path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762540902580-BangToaDo_2025.xls", "userId": 3, "districtId": "b246ae91-2e2e-4f29-8a6b-29be23b6e663", "provinceId": "f851f9a1-330b-4d29-98ae-f4092e7e7f70", "originalname": "BangToaDo_2025.xls"}	completed	0	0	0	f	2025-11-08 01:41:42.586811+07	2025-11-08 01:41:43.982117+07	\N	\N	00:15:00	2025-11-08 01:41:42.586811+07	2025-11-08 01:41:44.253206+07	2025-11-22 01:41:42.586811+07	f	{"created": 0, "skipped": 0, "totalRows": 1, "duplicates": 0, "skippedRows": [{"x": 2318587, "y": 428692, "row": 2, "name": "Luồng vào cảng Cái Lân tại cầu Bãi Cháy", "reason": "conversion_failed"}], "notConverted": 1}
23cd2bfe-17cd-4ddb-a932-9e07d80bfded	area-xlsx-import	0	{"area": 200, "path": "D:\\\\DATN-20220819T101500Z-001\\\\DATN\\\\complete\\\\backend-express\\\\uploads\\\\1762541414222-BangToaDo_2025.xls", "userId": 3, "area_type": "oyster", "districtId": "b246ae91-2e2e-4f29-8a6b-29be23b6e663", "provinceId": "f851f9a1-330b-4d29-98ae-f4092e7e7f70", "originalname": "BangToaDo_2025.xls"}	completed	0	0	0	f	2025-11-08 01:50:14.229368+07	2025-11-08 01:50:14.315725+07	\N	\N	00:15:00	2025-11-08 01:50:14.229368+07	2025-11-08 01:50:16.592781+07	2025-11-22 01:50:14.229368+07	f	{"created": 98, "skipped": 0, "totalRows": 99, "duplicates": 1, "skippedRows": [{"row": 2, "name": "Luồng vào cảng Cái Lân tại cầu Bãi Cháy", "reason": "duplicate_name"}], "notConverted": 0}
6e7639a4-3628-4bf8-a773-790b728a456e	__pgboss__maintenance	0	\N	completed	0	0	0	f	2025-11-07 21:37:20.659416+07	2025-11-07 21:37:20.68147+07	__pgboss__maintenance	\N	00:15:00	2025-11-07 21:37:20.659416+07	2025-11-07 21:37:20.751843+07	2025-11-07 21:45:20.659416+07	f	\N
8e690517-d306-447a-830f-5c291d1e8eba	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:37:20.96927+07	2025-11-07 21:37:24.832596+07	\N	2025-11-07 14:37:00	00:15:00	2025-11-07 21:37:20.96927+07	2025-11-07 21:37:24.851695+07	2025-11-07 21:38:20.96927+07	f	\N
9618ed0a-36dd-4032-a198-23a3dfc91105	__pgboss__cron	0	\N	completed	2	0	0	f	2025-11-07 21:38:01.848991+07	2025-11-07 21:38:04.897224+07	\N	2025-11-07 14:38:00	00:15:00	2025-11-07 21:37:24.848991+07	2025-11-07 21:38:04.907087+07	2025-11-07 21:39:01.848991+07	f	\N
\.


--
-- TOC entry 5027 (class 0 OID 305073)
-- Dependencies: 239
-- Data for Name: schedule; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.schedule (name, cron, timezone, data, options, created_on, updated_on) FROM stdin;
\.


--
-- TOC entry 5028 (class 0 OID 305082)
-- Dependencies: 240
-- Data for Name: subscription; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.subscription (event, name, created_on, updated_on) FROM stdin;
\.


--
-- TOC entry 5024 (class 0 OID 305028)
-- Dependencies: 236
-- Data for Name: version; Type: TABLE DATA; Schema: pgboss; Owner: postgres
--

COPY pgboss.version (version, maintained_on, cron_on) FROM stdin;
20	2025-11-08 01:49:39.824165+07	2025-11-08 01:50:03.995616+07
\.


--
-- TOC entry 5007 (class 0 OID 296845)
-- Dependencies: 219
-- Data for Name: SequelizeMeta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."SequelizeMeta" (name) FROM stdin;
20250115000000-add-description-to-naturalelements.js
20250108000000-add-central-meridian-to-provinces.js
20250115000001-fix-prediction-timestamps.js
20250606090000-create-email-subscriptions-table.js
20250606090001-create-otp-table.js
\.


--
-- TOC entry 5008 (class 0 OID 296848)
-- Dependencies: 220
-- Data for Name: diagnose_areas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnose_areas (id, name, latitude, longitude, area, area_type, province, district) FROM stdin;
159	Luồng vào cảng Cái Lân tại cầu Bãi Cháy	20.959162181938147	107.06615134258728	0	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
217	Lạch Vông Vang Cống Thẻ	20.998598327434156	107.46169691862929	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
218	Cửa Đối	20.969145645843756	107.56104973475357	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
219	Lạch giữa đảo Thẻ Vàng đảo Vạn Duôi	20.92662619589785	107.33178239760008	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
220	Lạch Đằng Chén phía Tây đảo Đồng Chén	20.937690120183326	107.41741148800665	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
221	Lạch Đầu Gỗ phía Đông đảo Đồng Chén	20.94270306370714	107.44630412400109	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
222	Lạch Cổng Nứa giữa đảo Cổng Nứa, đảo Trà Bản	20.954606197708376	107.47702283966706	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
223	Vùng Đá Bạc phía Đông đảo Trà Bàn	20.919743505095482	107.51010980253214	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
224	Luồng Con Quýt phía Tây Bắc đảo Trà Bàn	21.002498988737717	107.54853163851276	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
225	Luồng Con Quýt phía Đông đảo Cái Lim	21.089948337481125	107.57481494148783	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
226	Lạch Vồng Vang phía Bắc đảo Trà Bàn	21.02518063533757	107.50705530960741	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
227	Lạch đảo Cống Đông Cống Tây	20.889659731979403	107.31218054435033	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
228	Ven bờ khu Cống Yên phía Bắc đảo Ngọc Vừng	20.838677079715794	107.34869682445238	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
229	Cửa sông Rút sông sông Bạch Đằng , phía Tây xã Tiền Phong	20.837561962042685	106.8283169595983	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
230	Cửa sông Chanh, phía Đông Bắc xã Tiền Phong	20.85674457000859	106.86562747075781	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
231	Cửa sông Kênh Trai , giáp ranh xã Tân An Hoàng Tân	20.930157429882804	106.88473254181545	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
232	Luồng sông Voi Lớn , phía Nam xã Đồng Rui , Tiên Yên	19.373653933967546	107.38869349005316	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
233	Luồng sông Voi Lớn , ven bờ xã Hải Lạng , Tiên Yên	21.268755483257777	107.4070272998291	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
234	Khu vực cảng Mũi Chùa (cửa sông Tiên Yên)	21.285598354361497	107.45824026133052	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
235	Khu vực Hòn Thạch , Đầm Hà	21.23863940352443	107.58659624786267	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
236	Khu vực ven bờ xã Đầm Hà , huyện Đầm Hà (cửa sông Đầm Hà)	19.509536767260318	107.63051001799089	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
237	Khu vực cửa sông Đường Hoa, huyện Hải Hà	21.345697520167974	107.68433887071012	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
238	Khu vực Bắc Hòn Mỹ ,Hải Hà	21.358850706308445	107.7236641493404	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
239	Khu vực ven bờ xã Quảng Phong, Hải Hà (phía Bắc Đảo Miễu)	21.37460557409832	107.75182000674211	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
240	Khu bến phà Cái Chiên phía Bắc đảo Cái Chiên, Hải Hà	21.33179994817831	107.75797981008596	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
241	Bãi tắm Đầu Rồng xã Cái Chiên, Hải Hà	21.30688812804376	107.74710572209693	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
242	Ven bờ phía Tây đảo Vĩnh Thực Móng Cái	21.360982387753687	107.83223818400869	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
243	Ven bờ xã Quảng Nghĩa (cửa sông Thín Coóng và sông MaHam), Móng Cái	21.46372373084698	107.82026311289053	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
244	Ven bờ phường Hải Yên (cửa sông Bến Mười  lạch Hải Yên), Móng Cái	21.499248085416152	107.90208679034285	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
245	Khu vực cửa sông KaLong (phía Đông Bắc đảo Vĩnh Thực)	21.41770147104518	107.95453527877105	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
246	Khu vực ven bờ Núi Tổ Chim, Hải Hoà, Móng Cái (cửa sông Ka Long, Bắc Luân)	21.511162386243875	108.03856349508379	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
247	Bãi tắm Trà Cổ	21.477992278958087	108.02988056646971	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
248	Khu vực cảng Cô Tô	20.969457714167223	107.7619707778704	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
249	Khu Vụng cát 2, 3 thuộc khu 4 thị trấn Cô Tô	20.953270718394872	107.74045821940703	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
250	Khu vực bãi tắm Hồng Vằn, xã Đồng Tiến	21.005408420482134	107.76820705346007	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
251	Khu vực ven bờ phía Nam xã Đồng Tiến	20.987568991402142	107.7401194015108	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
252	Khu vực phía Bắc đảo Cô Tô con	21.047908154317795	107.7703194746732	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
253	Khu vực phía Nam đảo Cô Tô con	21.033256641484588	107.77123150600036	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
254	Khu vực phía Đông đảo Cô Tô con	21.04230585600181	107.78248070478735	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
255	Khu vực phía Tây đảo Cô Tô con	21.041016824215543	107.76205346058175	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
256	Khu vực cảng Thanh Lân	21.000594911216012	107.8051921049969	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
257	Khu vực nuôi nhuyễn thể phía Đông Nam đảo Thanh Lân	20.98725292735425	107.80607208499332	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
160	Cảng B12 vịnh Cửa Lục	20.96435217803022	107.06298321192442	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
161	Cảng Cái Lân vịnh Cửa Lục	20.97430337426687	107.05564809817825	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
162	Khu Hòn Gạc vịnh Cửa Lục	20.97604558407026	107.07562431555894	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
163	Ven bờ khu đô thị CENCO 5	20.966507442802016	107.07339760966798	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
164	Cửa sông Trới ven bờ KCN Việt Hưng	20.99116917628087	107.00693202059352	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
165	Cửa sông Mằn tại cầu Đá Trắng đường Trới, Vũ Oai	21.01754854379971	107.05729507827441	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
166	Cửa sông Diễn Vọng tại cầu Bang	21.013669586423866	107.11652106566021	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
167	Bến phà Tuần Châu	20.916720976611735	106.98988047769967	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
51	 BỜ HUYỆN THÁI THỤY	20.589080994085194	106.62052141945819	1000	oyster	8830da77-668b-48d0-b2b6-91f2d3d3d136	3de66096-313d-48bb-a7a0-627263a09e92
52	Bờ biển Vân Đồn	21.050620522816715	107.42779882321213	1000	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
53	Bờ biển Cát Bà	20.862621499274244	106.95327187274789	1000	cobia	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
168	Bãi tắm Tuần Châu	20.92786262869644	106.99499655344314	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
169	Cửa sông Hòn Dấu	20.944143320582832	106.92192859231307	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
170	Bãi tắm Bãi Cháy phía Tây bãi tắm giáp Đảo Rều	20.94378504482177	107.03010735175567	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
171	Bãi tắm Bãi Cháy khu Trung tâm bãi tắm	20.94354988564352	107.04517509726406	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
172	Ven bờ phường Hùng Thắng	20.949804012394466	107.0077037271749	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
173	Sau chợ Hạ Long 1 cầu Bài Thơ Hạ Long	20.946861679759976	107.08257232891548	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
174	Ven bờ khu vực Bến Đoan Hạ Long	20.949194850529988	107.0949369834754	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
175	Ven bờ khu vực cột 5 Phường Hồng Hà TP Hạ Long	20.9472786910555	107.09932988683137	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
176	Lạch Hạm Cầu Trắng TP Hạ Long	20.940962588669617	107.13274010430327	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
177	Lạch Lộ Phong, TP Hạ Long	20.940797930334018	107.20648750362102	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
178	Cảng km 6 TP Cẩm Phả	20.99219613618137	107.24840108068064	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
179	Cảng Vũng Đục TP Cẩm Phả	20.99062819184977	107.29814236379771	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
180	Khu vực Hòn Lướt ven cụm công nghiệp Cẩm Thịnh	20.99477600141868	107.34936806153273	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
181	Ven bờ Nhiệt điện Cẩm Phả tuyển than Cửa Ông	21.0071155052356	107.3653321938436	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
182	Cảng Cửa Ông TP Cẩm Phả	21.02775928111663	107.37514050208326	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
183	Cảng Cái Rồng Vân Đồn	21.059577565589297	107.43054596447462	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
184	Khu vực cảng 10 10 Cẩm Phả	20.98618737410906	107.32396086506691	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
185	Khu vực cửa sông Mông Dương  Cẩm Phả	21.07114317150012	107.36682301314848	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
186	Khu vực ven bờ xã Cẩm Hải, TP Cẩm Phả	21.09352677603645	107.3710679917321	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
187	Luồng Voi Lớn phía Tây xã Đoàn Kết Vân Đồn	21.102382604088348	107.39363668091852	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
188	Ven bờ Đông Nam xã Đông Xá	21.036885874625366	107.40227870961992	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
189	Ven bờ Đông xã Hạ Long Vân Đồn	21.075483107219032	107.46540812044425	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
190	Cảng Vạn Hoa xã Vạn Yên Vân Đồn	21.209317324334354	107.56709366940699	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
191	Thiên Cung Đầu Gỗ	20.912080792504643	107.01943465146813	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
192	Đảo TiTop	20.85858196329822	107.08154047939503	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
193	Khu nghỉ đêm Cát Lán	20.856568608023522	107.08875648538047	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
194	Khu nghỉ đêm Hang Luồn	20.854405094119077	107.09457959914269	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
195	Bồ Nâu Sửng Sốt	20.84545191304109	107.08941042101243	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
196	Khu nghỉ đêm Lởm Bò	20.82878849455204	107.08522689943847	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
197	Khu nghỉ đêm Cống Đỏ	20.876395135978825	107.11737710922097	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
198	Làng chài Ba Hang	20.90156912095819	107.01783225059695	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
199	Làng chài Hoa Cương	20.87418755929315	107.03181373855399	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
200	Làng chài Cửa Vạn	20.80526064483108	107.11933619436046	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
201	Làng chài Cống Tầu	20.75674060127827	107.14818407191711	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
202	Làng chài Vông Viêng	20.84241054613107	107.1620073221122	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
203	Làng chài Cống Đầm	20.84689128208509	107.28232393165746	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
204	Bãi Dài Vân Đồn	21.107007666575505	107.48790157785842	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
205	Bãi tắm Minh Châu xã Minh Châu, Vân Đồn	20.944485211020012	107.55270557932224	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
206	Bãi tắm Sơn Hào xã Quan Lạn, Vân Đồn	20.897546476584196	107.52114180994417	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
207	Bãi tắm Quan Lạn xã Quan Lạn, Vân Đồn	20.866067291044416	107.49619257803788	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
208	Bãi tắm Ngọc Vừng xã Ngọc Vừng, Vân Đồn	20.806226288151407	107.35856227041977	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
209	Luồng giữa Cửa Lục	20.8494618981317	107.0685317415317	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
210	Luồng khu Hòn Một	20.86468084196082	107.0960438351334	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
211	Luồng khu Áng Dù	20.78763152279621	107.15037654841414	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
212	Luồng Hang Trống	20.78410956607754	107.20766513377447	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
213	Luồng khu Trà Giới	20.847118507997237	107.24160946918434	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
214	Luồng khu Đông Tráng	20.841298563166763	107.2986568885555	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
215	Cảng Hòn Nét	20.90985967707759	107.26940122326158	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
216	Luồng Cửa Ông	20.967593402562606	107.348161480395	200	oyster	f851f9a1-330b-4d29-98ae-f4092e7e7f70	b246ae91-2e2e-4f29-8a6b-29be23b6e663
\.


--
-- TOC entry 5010 (class 0 OID 296853)
-- Dependencies: 222
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
-- TOC entry 5012 (class 0 OID 296857)
-- Dependencies: 224
-- Data for Name: diagnose_prediction_natureelements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnose_prediction_natureelements (id, prediction_id, nature_element_id, value) FROM stdin;
551	62	10	8.01
552	62	14	20.3
553	62	12	28
554	62	21	18.2
555	63	10	8.05
556	63	14	26.7
557	63	12	28.4
558	63	21	27.1
559	64	10	8.23
560	64	14	28.5
561	64	12	27.6
562	64	21	28.3
563	65	10	8.2
564	65	14	23.3
565	65	12	28.2
566	65	21	22.6
\.


--
-- TOC entry 5014 (class 0 OID 296861)
-- Dependencies: 226
-- Data for Name: diagnose_predictions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.diagnose_predictions (id, user_id, area_id, prediction_text, "createdAt", "updatedAt") FROM stdin;
62	5	51	-1	2025-02-01 19:00:00+07	2025-10-05 20:44:44.796+07
63	5	51	0	2025-05-01 19:00:00+07	2025-10-05 20:44:45.922+07
64	5	51	-1	2025-08-01 19:00:00+07	2025-10-05 20:44:46.803+07
65	5	51	-1	2025-11-01 19:00:00+07	2025-10-05 20:44:47.89+07
\.


--
-- TOC entry 5019 (class 0 OID 296951)
-- Dependencies: 231
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
665df479-786d-44da-90ad-c77d493c18f7	Quảng Ngãi	15.1216	108.8043	2b708477-89e2-4f2c-98ce-11c6de5d9d1a
a3c6f9f5-5058-443e-8c4e-7e9e3b6d5615	Đức Phổ	14.8397	109.0134	2b708477-89e2-4f2c-98ce-11c6de5d9d1a
ab02b04a-b3fc-4e5f-94e8-f27de6016c50	Sơn Tịnh	15.2124	108.7422	2b708477-89e2-4f2c-98ce-11c6de5d9d1a
5ea9b0d1-5f54-456d-939f-bf7592b51d29	Nha Trang	12.2388	109.1967	0516f5a8-0e1e-4c95-90f7-50e59c99ad20
6c9e1e03-2d6f-4b17-83f8-c2b3e79dbe81	Cam Ranh	11.9214	109.1597	0516f5a8-0e1e-4c95-90f7-50e59c99ad20
110b11e2-35e1-41e4-9d0a-14cb23efbd6f	Ninh Hòa	12.5356	109.0912	0516f5a8-0e1e-4c95-90f7-50e59c99ad20
3de66096-313d-48bb-a7a0-627263a09e92	Thái Thuỵ	20.45	106.34	8830da77-668b-48d0-b2b6-91f2d3d3d136
\.


--
-- TOC entry 5021 (class 0 OID 305001)
-- Dependencies: 233
-- Data for Name: email_subscriptions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_subscriptions (id, email, area_id, is_active, unsubscribe_token, created_at, updated_at) FROM stdin;
7	nghiem.eo.bua.18@gmail.com	51	t	36f27ff7de980c66b4f6e3ba9d0aaf8c0b9184ab7776de1f6362e770887b4d7d	2025-10-05 21:07:07.741+07	2025-10-05 21:07:07.743+07
\.


--
-- TOC entry 5023 (class 0 OID 305018)
-- Dependencies: 235
-- Data for Name: otps; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.otps (id, email, area_id, otp_code, expires_at, is_used, created_at, updated_at) FROM stdin;
2	nghiem.ld215102@sis.hust.edu.vn	49	923330	2025-09-17 02:57:01.449+07	t	2025-09-17 02:52:01.495+07	2025-09-17 02:52:25.913+07
3	nghiem.eo.bua.18@gmail.com	49	858264	2025-09-21 20:43:11.949+07	t	2025-09-21 20:38:11.976+07	2025-09-21 20:38:50.415+07
4	nghiem.eo.bua.18@gmail.com	51	238198	2025-10-05 21:11:30.067+07	t	2025-10-05 21:06:30.091+07	2025-10-05 21:07:07.691+07
\.


--
-- TOC entry 5018 (class 0 OID 296946)
-- Dependencies: 230
-- Data for Name: provinces; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.provinces (id, name, central_meridian) FROM stdin;
8830da77-668b-48d0-b2b6-91f2d3d3d136	Thái Bình	\N
afe44c08-925d-44a1-b24a-ba45e3fea3bb	An Giang	104.75
ca0ca456-17eb-4f26-9a5a-7f9647fa1f61	Cà Mau	104.5
d58b3ce3-4978-430e-984c-b01ee7946096	Cần Thơ	105
95394a8c-0053-4fb1-82ad-4d65922091c5	Đà Nẵng	107.75
bf327e34-6fed-48b3-a01b-47489b48887a	Đắk Lắk	108.5
b296afe0-56ce-4136-8485-65061b38beb5	Điện Biên	103
de5b8fae-f13f-4206-a8a6-39032fc553b7	Đồng Nai	107.75
082b4ab0-9366-4888-b34d-5aab03925f27	Đồng Tháp	105
6bb082d5-b361-4ac7-ae15-23ba463fa3f8	Gia Lai	108.25
d29e4e82-63d2-4d19-b852-7198592b04de	Hà Nội	105
10ef86e4-3851-44e9-8aeb-5cf21bbff1a2	Hà Tĩnh	105.5
fb7e3341-2d65-44ba-868a-1c89c85e36a1	Hải Phòng	105.75
d4347331-3b5e-4837-ba0a-7f0be3fef5fd	Hưng Yên	105.5
0516f5a8-0e1e-4c95-90f7-50e59c99ad20	Khánh Hoà	108.25
b4e406b2-cf84-4bca-875b-ad277208e71e	Lào Cai	104.75
fdca33cf-6b24-409b-9d07-46efb37051f5	Thừa Thiên Huế	107
faf5c0c2-ec3f-4919-b9d6-fa71ecbd4d60	Lạng Sơn	107.25
9c9fcd95-e3b7-4dc8-9dd8-165fa62eeee4	Lâm Đồng	107.75
799ee009-6e6c-4e5d-b9a8-91ab717d3087	Nghệ An	104.75
5e788a77-0373-4ac7-8d76-64f2a30883bc	Ninh Bình	105
03d29202-71a6-4d81-b854-b46b454d9502	Phú Thọ	104.75
2b708477-89e2-4f2c-98ce-11c6de5d9d1a	Quảng Ngãi	108
f851f9a1-330b-4d29-98ae-f4092e7e7f70	Quảng Ninh	107.75
f1b738d5-d170-4859-83e3-2a2b2a76c9b0	Quảng Trị	106
d039c2b9-6098-4169-8bc3-9030c916ec0a	Sơn La	104
9560f870-f7e3-4c1c-93fe-32b60feb4d0f	Tây Ninh	105.75
cf33a262-2397-4fe5-b184-53a27e19e08e	Thanh Hoá	105
b56da993-5bb6-4fe4-897b-55f7f2e51ab8	Thái Nguyên	106.5
88ed4ab0-b432-40f8-a8c4-35c3b2552d40	TP Hồ Chí Minh	105.75
0f81fdb7-043d-43ef-bf66-021e11e9a32e	Tuyên Quang	106
6e8c3653-97b3-4161-b240-6a8017c19d40	Lai Châu	103
a33cb85c-5178-40bf-8466-f6d7919e2f08	Cao Bằng	105.75
edcfffe4-74c9-44b8-ab70-3b3ac311cbac	Bắc Ninh	107
cef9837c-4bd8-4bde-b9fe-332e2c4c49b2	Vĩnh Long	105.5
\.


--
-- TOC entry 5016 (class 0 OID 296882)
-- Dependencies: 228
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
-- TOC entry 5043 (class 0 OID 0)
-- Dependencies: 221
-- Name: diagnose_areas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_areas_id_seq', 257, true);


--
-- TOC entry 5044 (class 0 OID 0)
-- Dependencies: 223
-- Name: diagnose_naturalelements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_naturalelements_id_seq', 21, true);


--
-- TOC entry 5045 (class 0 OID 0)
-- Dependencies: 225
-- Name: diagnose_prediction_natureelements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_prediction_natureelements_id_seq', 566, true);


--
-- TOC entry 5046 (class 0 OID 0)
-- Dependencies: 227
-- Name: diagnose_predictions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diagnose_predictions_id_seq', 65, true);


--
-- TOC entry 5047 (class 0 OID 0)
-- Dependencies: 232
-- Name: email_subscriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.email_subscriptions_id_seq', 7, true);


--
-- TOC entry 5048 (class 0 OID 0)
-- Dependencies: 234
-- Name: otps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.otps_id_seq', 4, true);


--
-- TOC entry 5049 (class 0 OID 0)
-- Dependencies: 229
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 13, true);


--
-- TOC entry 4843 (class 2606 OID 305067)
-- Name: job job_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- TOC entry 4851 (class 2606 OID 305081)
-- Name: schedule schedule_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.schedule
    ADD CONSTRAINT schedule_pkey PRIMARY KEY (name);


--
-- TOC entry 4853 (class 2606 OID 305090)
-- Name: subscription subscription_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.subscription
    ADD CONSTRAINT subscription_pkey PRIMARY KEY (event, name);


--
-- TOC entry 4839 (class 2606 OID 305032)
-- Name: version version_pkey; Type: CONSTRAINT; Schema: pgboss; Owner: postgres
--

ALTER TABLE ONLY pgboss.version
    ADD CONSTRAINT version_pkey PRIMARY KEY (version);


--
-- TOC entry 4811 (class 2606 OID 296897)
-- Name: SequelizeMeta SequelizeMeta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."SequelizeMeta"
    ADD CONSTRAINT "SequelizeMeta_pkey" PRIMARY KEY (name);


--
-- TOC entry 4813 (class 2606 OID 296899)
-- Name: diagnose_areas diagnose_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_areas
    ADD CONSTRAINT diagnose_areas_pkey PRIMARY KEY (id);


--
-- TOC entry 4815 (class 2606 OID 296901)
-- Name: diagnose_naturalelements diagnose_naturalelements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_naturalelements
    ADD CONSTRAINT diagnose_naturalelements_pkey PRIMARY KEY (id);


--
-- TOC entry 4817 (class 2606 OID 296903)
-- Name: diagnose_prediction_natureelements diagnose_prediction_natureelements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements
    ADD CONSTRAINT diagnose_prediction_natureelements_pkey PRIMARY KEY (id);


--
-- TOC entry 4819 (class 2606 OID 296905)
-- Name: diagnose_predictions diagnose_predictions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions
    ADD CONSTRAINT diagnose_predictions_pkey PRIMARY KEY (id);


--
-- TOC entry 4827 (class 2606 OID 296955)
-- Name: districts districts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_pkey PRIMARY KEY (id);


--
-- TOC entry 4831 (class 2606 OID 305009)
-- Name: email_subscriptions email_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_subscriptions
    ADD CONSTRAINT email_subscriptions_pkey PRIMARY KEY (id);


--
-- TOC entry 4833 (class 2606 OID 305011)
-- Name: email_subscriptions email_subscriptions_unsubscribe_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_subscriptions
    ADD CONSTRAINT email_subscriptions_unsubscribe_token_key UNIQUE (unsubscribe_token);


--
-- TOC entry 4837 (class 2606 OID 305024)
-- Name: otps otps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otps
    ADD CONSTRAINT otps_pkey PRIMARY KEY (id);


--
-- TOC entry 4825 (class 2606 OID 296950)
-- Name: provinces provinces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provinces
    ADD CONSTRAINT provinces_pkey PRIMARY KEY (id);


--
-- TOC entry 4835 (class 2606 OID 313221)
-- Name: email_subscriptions unique_email_area_pair; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_subscriptions
    ADD CONSTRAINT unique_email_area_pair UNIQUE (email, area_id);


--
-- TOC entry 4821 (class 2606 OID 296913)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4823 (class 2606 OID 296915)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 4848 (class 1259 OID 305093)
-- Name: archive_archivedon_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX archive_archivedon_idx ON pgboss.archive USING btree (archivedon);


--
-- TOC entry 4849 (class 1259 OID 305091)
-- Name: archive_id_idx; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX archive_id_idx ON pgboss.archive USING btree (id);


--
-- TOC entry 4840 (class 1259 OID 305095)
-- Name: job_fetch; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_fetch ON pgboss.job USING btree (name text_pattern_ops, startafter) WHERE (state < 'active'::pgboss.job_state);


--
-- TOC entry 4841 (class 1259 OID 305094)
-- Name: job_name; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE INDEX job_name ON pgboss.job USING btree (name text_pattern_ops);


--
-- TOC entry 4844 (class 1259 OID 305099)
-- Name: job_singleton_queue; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singleton_queue ON pgboss.job USING btree (name, singletonkey) WHERE ((state < 'active'::pgboss.job_state) AND (singletonon IS NULL) AND (singletonkey ~~ '\_\_pgboss\_\_singleton\_queue%'::text));


--
-- TOC entry 4845 (class 1259 OID 305098)
-- Name: job_singletonkey; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonkey ON pgboss.job USING btree (name, singletonkey) WHERE ((state < 'completed'::pgboss.job_state) AND (singletonon IS NULL) AND (NOT (singletonkey ~~ '\_\_pgboss\_\_singleton\_queue%'::text)));


--
-- TOC entry 4846 (class 1259 OID 305097)
-- Name: job_singletonkeyon; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonkeyon ON pgboss.job USING btree (name, singletonon, singletonkey) WHERE (state < 'expired'::pgboss.job_state);


--
-- TOC entry 4847 (class 1259 OID 305096)
-- Name: job_singletonon; Type: INDEX; Schema: pgboss; Owner: postgres
--

CREATE UNIQUE INDEX job_singletonon ON pgboss.job USING btree (name, singletonon) WHERE ((state < 'expired'::pgboss.job_state) AND (singletonkey IS NULL));


--
-- TOC entry 4828 (class 1259 OID 313222)
-- Name: email_subscriptions_area_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX email_subscriptions_area_id ON public.email_subscriptions USING btree (area_id);


--
-- TOC entry 4829 (class 1259 OID 313223)
-- Name: email_subscriptions_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX email_subscriptions_email ON public.email_subscriptions USING btree (email);


--
-- TOC entry 4856 (class 2606 OID 296921)
-- Name: diagnose_prediction_natureelements diagnose_prediction_natureelements_nature_element_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements
    ADD CONSTRAINT diagnose_prediction_natureelements_nature_element_id_fkey FOREIGN KEY (nature_element_id) REFERENCES public.diagnose_naturalelements(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4857 (class 2606 OID 296926)
-- Name: diagnose_prediction_natureelements diagnose_prediction_natureelements_prediction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_prediction_natureelements
    ADD CONSTRAINT diagnose_prediction_natureelements_prediction_id_fkey FOREIGN KEY (prediction_id) REFERENCES public.diagnose_predictions(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4858 (class 2606 OID 296931)
-- Name: diagnose_predictions diagnose_predictions_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions
    ADD CONSTRAINT diagnose_predictions_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.diagnose_areas(id) ON UPDATE CASCADE;


--
-- TOC entry 4859 (class 2606 OID 296936)
-- Name: diagnose_predictions diagnose_predictions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_predictions
    ADD CONSTRAINT diagnose_predictions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE;


--
-- TOC entry 4860 (class 2606 OID 296956)
-- Name: districts districts_province_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.districts
    ADD CONSTRAINT districts_province_id_fkey FOREIGN KEY (province_id) REFERENCES public.provinces(id);


--
-- TOC entry 4861 (class 2606 OID 305012)
-- Name: email_subscriptions email_subscriptions_area_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_subscriptions
    ADD CONSTRAINT email_subscriptions_area_id_fkey FOREIGN KEY (area_id) REFERENCES public.diagnose_areas(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4854 (class 2606 OID 296966)
-- Name: diagnose_areas fk_district; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_areas
    ADD CONSTRAINT fk_district FOREIGN KEY (district) REFERENCES public.districts(id);


--
-- TOC entry 4855 (class 2606 OID 296961)
-- Name: diagnose_areas fk_province; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diagnose_areas
    ADD CONSTRAINT fk_province FOREIGN KEY (province) REFERENCES public.provinces(id);


-- Completed on 2025-11-08 01:50:46

--
-- PostgreSQL database dump complete
--

