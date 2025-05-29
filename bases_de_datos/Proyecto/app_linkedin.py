import streamlit as st
import pandas as pd

st.title("LinkedIn Job Postings - Análisis Exploratorio")
st.markdown("### Grupo: Agarrini la Palini")
st.markdown("**Integrantes:** Adolfo Rojas, Benjamín Durán, Camila Paredes, Tomás Albornoz")
st.markdown("**Fuente del dataset:** [Kaggle - LinkedIn Job Postings](https://www.kaggle.com/datasets/arshkon/linkedin-job-postings/data)")

st.header("Descripción de los datasets")
st.subheader("postings.csv")
st.markdown("Contiene detalles de publicaciones de empleo en LinkedIn.")

data_postings = {
    "Campo": [
        "job_id", "company_id", "title", "description", "max_salary", "med_salary", "min_salary",
        "pay_period", "formatted_work_type", "location", "applies", "original_listed_time",
        "remote_allowed", "views", "job_posting_url", "application_url", "application_type", "expiry",
        "closed_time", "formatted_experience_level", "skills_desc", "listed_time", "posting_domain",
        "sponsored", "work_type", "currency", "compensation_type"
    ],
    "Descripción": [
        "ID del empleo según LinkedIn (enlace a la oferta)",
        "Identificador de la empresa (relacionado con companies.csv)",
        "Título del trabajo",
        "Descripción del trabajo",
        "Salario máximo",
        "Salario medio",
        "Salario mínimo",
        "Período de pago (Hourly, Monthly, Yearly)",
        "Tipo de trabajo (Fulltime, Parttime, Contract)",
        "Ubicación del trabajo",
        "Número de postulaciones",
        "Tiempo original de publicación",
        "Si permite trabajo remoto",
        "Número de visualizaciones",
        "URL de la publicación",
        "URL para enviar postulaciones",
        "Tipo de proceso de aplicación (offsite, complejo/simple onsite)",
        "Fecha de expiración de la oferta",
        "Fecha de cierre de la publicación",
        "Nivel de experiencia requerido (entry, associate, executive, etc)",
        "Descripción de habilidades requeridas",
        "Fecha de publicación",
        "Dominio del sitio con el formulario de aplicación",
        "Indica si la publicación está patrocinada",
        "Tipo de trabajo asociado",
        "Moneda del salario",
        "Tipo de compensación"
    ]
}

df_postings_desc = pd.DataFrame(data_postings)
st.dataframe(df_postings_desc, use_container_width=True)

st.subheader("company_details/companies.csv")
st.markdown("Detalles de las empresas asociadas con las publicaciones de empleo.")

data_companies = {
    "Campo": [
        "company_id", "name", "description", "company_size", "country",
        "state", "city", "zip_code", "address", "url"
    ],
    "Descripción": [
        "ID de la empresa según LinkedIn",
        "Nombre de la empresa",
        "Descripción de la empresa",
        "Tamaño de la empresa (0 más pequeña - 7 más grande)",
        "País de la sede",
        "Estado de la sede",
        "Ciudad de la sede",
        "Código postal de la sede",
        "Dirección de la sede",
        "Enlace al perfil de LinkedIn de la empresa"
    ]
}

df_companies_desc = pd.DataFrame(data_companies)
st.dataframe(df_companies_desc, use_container_width=True)

st.subheader("company_details/company_industries")

df_company_industries = pd.DataFrame({
    "Columna": ["company_id", "industry"],
    "Descripción": [
        "ID de la empresa (PK, referencia a `companies`)",
        "ID de la industria"
    ]
})
st.dataframe(df_company_industries, use_container_width=True)


st.subheader("company_details/company_specialities")

df_company_specialities = pd.DataFrame({
    "Columna": ["company_id", "speciality"],
    "Descripción": [
        "ID de la empresa (PK, referencia a `companies`)",
        "ID de la especialidad"
    ]
})
st.dataframe(df_company_specialities, use_container_width=True)


st.subheader("company_details/employee_counts.csv")
st.markdown("Registro del número de empleados y seguidores de las empresas.")

df_employee_counts = pd.DataFrame({
    "Campo": ["company_id", "employee_count", "follower_count", "time_recorded"],
    "Descripción": [
        "ID de la empresa",
        "Número de empleados en la empresa",
        "Número de seguidores en LinkedIn",
        "Timestamp en formato Unix de cuándo se recolectaron los datos"
    ]
})
st.dataframe(df_employee_counts, use_container_width=True)


st.subheader("job_details/benefits.csv")
st.markdown("Contiene información sobre los beneficios ofrecidos en los empleos.")

df_benefits = pd.DataFrame({
    "Campo": ["job_id", "type", "inferred"],
    "Descripción": [
        "ID del empleo",
        "Tipo de beneficio (401K, Seguro Médico, etc)",
        "Indica si el beneficio fue etiquetado explícitamente o inferido por LinkedIn"
    ]
})
st.dataframe(df_benefits, use_container_width=True)


st.subheader("job_details/job_industries")

df_job_industries = pd.DataFrame({
    "Columna": ["job_id", "industry_id"],
    "Descripción": [
        "ID del trabajo (PK, referencia a `postings`)",
        "ID de la industria (referencia a `industries`)"
    ]
})
st.dataframe(df_job_industries, use_container_width=True)

st.subheader("job_details/job_skills")

df_job_skills = pd.DataFrame({
    "Columna": ["job_id", "skill_abr"],
    "Descripción": [
        "ID del trabajo (PK, referencia a `postings`)",
        "Clave de habilidad (referencia a `skills`)"
    ]
})
st.dataframe(df_job_skills, use_container_width=True)


st.subheader("job_details/salaries")

df_salaries = pd.DataFrame({
    "Columna": [
        "salary_id", "job_id", "max_salary", "med_salary", "min_salary",
        "pay_period", "currency", "compensation_type"
    ],
    "Descripción": [
        "ID del salario",
        "ID del trabajo (referencia a la tabla `postings`)",
        "Salario máximo",
        "Salario medio",
        "Salario mínimo",
        "Periodo de pago (Por hora, Mensual, Anual)",
        "Moneda del salario",
        "Tipo de compensación (Fija, Variable, etc.)"
    ]
})
st.dataframe(df_salaries, use_container_width=True)


@st.cache_data
def load_data():
    df_postings = pd.read_csv("postings.csv", encoding="UTF-8", engine="python")
    df_companies = pd.read_csv("company_details/companies.csv", encoding="UTF-8", engine="python")
    return {
        "postings": df_postings,
        "companies": df_companies,
    }

def admite_multiples(df, col):
    if df[col].dtype == object:
        return df[col].dropna().str.contains(r'[,|;/]').any()
    return False

dfs = load_data()

for nombre, dataframe in dfs.items():
    st.subheader(f"Dataset: {nombre}")
    st.markdown(f"**Filas totales:** {dataframe.shape[0]}")
    st.markdown(f"**Columnas totales:** {dataframe.shape[1]}")

    nulos = dataframe.isnull().sum()
    unicos = dataframe.nunique()

    resumen = pd.DataFrame({
        "Valores únicos": unicos,
        "Valores nulos": nulos,
        "Porcentaje de nulos (%)": (nulos / dataframe.shape[0] * 100).round(2),
        "Tipo de dato": dataframe.dtypes,
        "Admite múltiples": dataframe.columns.to_series().apply(lambda col: admite_multiples(dataframe, col))
    })

    st.markdown("### Resumen de columnas")
    st.dataframe(resumen)

    num_registros = st.slider(f"Número de registros a mostrar de {nombre}", 1, 20, 5)
    st.markdown(f"### Primeros {num_registros} registros")
    st.dataframe(dataframe.head(num_registros))
