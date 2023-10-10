export default {
    methods: {
        async createProposta() {
            const toBase64 = file => new Promise((resolve, reject) => {
                const reader = new FileReader();
                reader.readAsDataURL(file);
                reader.onload = () => resolve(reader.result);
                reader.onerror = error => reject(error);
            });

            let formData = new FormData();

            let anexos64 = [];

            for (let i = 0; i < this.$store.state.proposta.anexos.length; i++) {
                anexos64.push(await toBase64(this.$store.state.proposta.anexos[i]));
            }

            //envia dados da proposta

            formData.append("app", "criaproposta");
            formData.append('name', this.$store.state.proposta.nome);
            formData.append('cpf', this.$store.state.proposta.cpf);
            formData.append('dataNasc', this.$store.state.proposta.dataNasc);
            formData.append('email', this.$store.state.proposta.email);
            formData.append('rg', this.$store.state.proposta.rg);
            formData.append('logradouro', this.$store.state.proposta.logradouro);
            formData.append('numero', this.$store.state.proposta.numero);
            formData.append('complemento', this.$store.state.proposta.complemento);
            formData.append('bairro', this.$store.state.proposta.bairro);
            formData.append('cidade', this.$store.state.proposta.cidade);
            formData.append('cep', this.$store.state.proposta.cep);
            formData.append('estado', this.$store.state.proposta.uf);
            formData.append('celular', this.$store.state.proposta.celular);
            formData.append('estCivil', this.$store.state.proposta.estCivil);
            formData.append('sexo', this.$store.state.proposta.sexo);
            formData.append('crematorio', this.$store.state.proposta.crematorio);
            formData.append('metodocobr', this.$store.state.proposta.mcobranca);
            formData.append('vencto', this.$store.state.proposta.vencto);
            formData.append('cod_vend', this.$route.query.vend ? this.$route.query.vend : null)

            //PLANO SELECIONADO
            switch (this.$route.query.plano) {
                case "Essencial":
                    formData.append('plano', 13);
                    break
                case "Clássico":
                    formData.append('plano', 14);
                    break
                case "Supremo":
                    formData.append('plano', 15);
                    break
                case "Adapt":
                    formData.append('plano', 17);
                    break
            }

            formData.append('filhos', this.$store.state.proposta.dependentes);

            let tempDependentes = this.$store.state.proposta.dependentes;

            for (let i = 0; i < tempDependentes.length; i++) {
                if(tempDependentes[i].valor == 0)
                    tempDependentes[i].cortesia = 's';
            }

            let tempBeneficiarios = this.$store.state.proposta.beneficiarios;

            formData.append('dependentes', JSON.stringify(tempDependentes));
            formData.append('beneficiarios', JSON.stringify(tempBeneficiarios));

            for (let i = 0; i < anexos64.length; i++) {
                formData.append('images[' + i + ']', anexos64[i]);
            }

            await this.$axios.post(this.url, formData, {

                headers: {
                    'Content-Type': 'multipart/form-data',
                    'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
                    'User-Agent': 'My-App',
                    'Accept': '*/*',
                }
            }).then();

            //ENVIA PDFs da proposta por email

            //GUARDA COD DA PROPOSTA

            let fdata = new FormData();
            let codigo;

            fdata.append("app", "getproposta");
            fdata.append("cpf", this.$store.state.proposta.cpf);

            await this.$axios.post(this.url, fdata, {

                headers: {
                    'Content-Type': 'multipart/form-data',
                    'x-api-key': 'e949f8ee3299e48ed653375016868b9b6d7a2c7b0619127ccebaa9766ee9ab57',
                    'User-Agent': 'My-App',
                    'Accept': '*/*',
                }
            }).then((response) => codigo = response.data.toString());
        }
    }
}