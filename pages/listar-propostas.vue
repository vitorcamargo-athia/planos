<template>
    <div v-if="$route.query.vend">
        <article class="panel is-info">
            <p class="panel-heading">
                Propostas pendentes
            </p>
            <div class="box">
                <table class="table is-striped is-narrow is-fullwidth">
                    <thead>
                        <tr>
                            <th>Código</th>
                            <th>Titular</th>
                            <th>Cidade</th>
                            <th>Cartão</th>
                            <th>Assinatura</th>
                            <th>Ação</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr v-for="(proposta, index) in propostas" :key="index">
                            <td>{{ proposta.COD_PROPOSTA }}</td>
                            <td>{{ proposta.NOME_TITULAR }}</td>
                            <td>{{ proposta.CIDADE }}</td>
                            <td>
                                <CheckIcon v-if="proposta.PAGTO == '1'" style="color:green" />
                                <MischeckIcon v-else style="color:red" />
                            </td>
                            <td>
                                <CheckIcon v-if="proposta.ASSIN == '1'" style="color:green" />
                                <MischeckIcon v-else style="color:red" />
                            </td>
                            <td><button @click="ir(proposta.COD_PROPOSTA)" class="button is-primary">Acessar</button></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </article>
    </div>
</template>
  
<script>
import CheckIcon from '~icons/mdi/check-bold';
import MischeckIcon from '~icons/icomoon-free/cross';
import U from '~/mixins/Url';

export default {
    name: "finalizacao",
    layout: 'blank',
    components: { CheckIcon, MischeckIcon },
    mixins:[Url],
    async mounted() {
        let fdata = new FormData();

        fdata.append("app", "getpropostasvendedor");
        fdata.append("cod_vendedor", this.$route.query.vend);

        await this.$axios.post(this.url, fdata, {

            headers: {
                'Content-Type': 'multipart/form-data',
                'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
                'User-Agent': 'My-App',
                'Accept': '*/*',
            }
        }).then((response) => this.propostas = response.data);
    },
    methods: {
        async ir(cod_proposta) {
            this.$router.push("/finalizacao?cod_proposta=" + cod_proposta + "&vend=" + this.$route.query.vend);
        }
    }
}
</script>
  
<style scoped></style>
  