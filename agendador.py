#!/usr/bin/env python
# coding: utf-8

# In[7]:


import streamlit as st
import pandas as pd
import altair as alt

# Título da página
st.title("Agendador de Bombeios")

# Exibir a data de amanhã no início da página
tomorrow = pd.to_datetime("today") + pd.Timedelta(days=1)
st.markdown(f"**Data:** {tomorrow.strftime('%d/%m/%Y')}")

# Inputs para coletar os dados
company = st.text_input("Companhia")
product = st.text_input("Produto")
quota = st.number_input("Cota", min_value=0.0, step=0.1)
start_time = st.text_input("Hora de Início (HH:MM)", "00:00")
end_time = st.text_input("Hora de Fim (HH:MM)", "00:00")

# Botão para adicionar a entrada de dados
if st.button("Adicionar Bombeio"):
    # Adiciona os dados em um DataFrame
    if "data" not in st.session_state:
        st.session_state.data = []

    # Combinar a data de amanhã com as horas de início e fim
    # Pega a data de amanhã e combina com as horas fornecidas
    try:
        start_datetime = pd.to_datetime(tomorrow.strftime("%Y-%m-%d") + " " + start_time)
        end_datetime = pd.to_datetime(tomorrow.strftime("%Y-%m-%d") + " " + end_time)
    except ValueError:
        st.error("Formato de hora inválido. Use HH:MM.")
        start_datetime = pd.NaT
        end_datetime = pd.NaT

    # Adicionar ao estado da sessão apenas se as datas forem válidas
    if pd.notna(start_datetime) and pd.notna(end_datetime):
        st.session_state.data.append({
            "Companhia": company,
            "Produto": product,
            "Cota": quota,
            "Início": start_datetime,
            "Fim": end_datetime
        })
        st.success("Bombeio adicionado com sucesso!")
    else:
        st.error("Erro ao adicionar o bombeio.")

# Exibir os dados adicionados
if "data" in st.session_state:
    df = pd.DataFrame(st.session_state.data)
    st.subheader("Dados de Bombeios Agendados")
    st.write(df)

    # Garantir que as colunas 'Início' e 'Fim' estão no formato datetime
    df['Início'] = pd.to_datetime(df['Início'], errors='coerce')
    df['Fim'] = pd.to_datetime(df['Fim'], errors='coerce')

    # Criar gráfico de Gantt usando Altair
    st.subheader("Gráfico Gantt de Bombeios")

    # Ajustar o gráfico para mostrar apenas horas no eixo X (formato 24 horas)
    chart = alt.Chart(df).mark_bar().encode(
        x=alt.X('hoursminutes(Início):T', title='Hora de Início', axis=alt.Axis(format='%H:%M', labelAngle=-45)),
        x2=alt.X('hoursminutes(Fim):T', title='Hora de Fim'),
        y='Companhia:N',
        color='Produto:N',
        tooltip=['Companhia', 'Produto', 'Cota', 'Início', 'Fim']
    ).properties(
        title='Gráfico Gantt de Bombeios (Amanhã)'
    )

    st.altair_chart(chart, use_container_width=True)



# In[4]:




