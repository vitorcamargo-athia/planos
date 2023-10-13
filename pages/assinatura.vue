<template>
    <div>
        <div class="row" v-if="this.error" style="text-align: center; font-size: 20px; margin-top: 50px;">
            <h2>{{ this.error }}</h2>
        </div>

        <div class="row" v-if="this.signPrepare" style="text-align: center; font-size: 20px; margin-top: 50px;">
            <h2>Estamos preparando o contrato para assinatura, aguarde a finalização.</h2>
        </div>

        <div class="row" v-if="this.success" style="text-align: center; font-size: 20px; margin-top: 50px;">
            <h2>Documento enviado para assinatura, verifique a caixa de email e siga a instruções.</h2>
            <a :href="'/finalizacao?cod_proposta=' + $route.query.cod_proposta + '&vend=' + $route.query.vend"
                class="btn btn-primary">Voltar</a>
        </div>

        <div class="row" v-if="this.cancelPrepare" style="text-align: center; font-size: 20px; margin-top: 50px;">
            <h2>Estamos cancelando o contrato.</h2>
        </div>

        <div class="row" v-if="this.cancelSuccess" style="text-align: center; font-size: 20px; margin-top: 50px;">
            <h2>Documento cancelado com sucesso.</h2>
            <a :href="'/finalizacao?cod_proposta=' + $route.query.cod_proposta + '&vend=' + $route.query.vend"
                class="btn btn-primary">Voltar</a>
        </div>

    </div>
</template>

<script>
import hmacSHA256 from 'crypto-js/hmac-sha256';
import Base64 from 'crypto-js/enc-base64';
import Url from '../mixins/Url';

export default {
    name: 'assinatura',
    layout: 'blank',
    mixins: [Url],
    data() {
        return {
            data: null,
            crypt: null,
            error: null,
            success: null,
            cancelPrepare: null,
            cancelSuccess: null,
            signPrepare: null,
            
            contrato: null,
            cod_doc: null
        }
    },
    mounted() {
        
        let uri = window.location.search.substring(1);
        let params = new URLSearchParams(uri);
        this.contrato = params.get("contrato");
        this.cod_doc = params.get("cod_doc");
        this.get(this.contrato);
    },
    methods: {
        get(contrato) {
            this.$axios
                .get(this.url_assinatura + 'getDadosContrato&cod_contrato=' + contrato + '&cod_doc=' + this.cod_doc + "&tipo=presential&email=&telefone=&pap=true", {
                    headers: {
                        'x-api-key': 'e949f8ee3299e48ed653375017868b9b6d7a2c7b06191278eebaa9766ee9ab55'
                    }
                }).then((response) => {
                    if (response.status == 200) {
                        this.data = response.data;

                        if (!this.data.clicksign.uuid) {
                            this.carregarTemplate();
                        } else {
                            this.cancelDocument(this.data.clicksign.uuid);
                        }
                    }
                });
        },
        async carregarTemplate() {
            this.signPrepare = true;

            var options = {
                method: 'POST',
                url: '/api/templates/' + this.data.clicksign.template + '/documents?access_token=' + this.token,

                headers: {
                    'Content-Type': 'application/json'
                },

                data: {
                    document: this.data.document
                }
            };

            try {
                const response = await this.$axios.request(options);
                if (response.status == 201) {
                    await this.registraSolicitacao(this.contrato, response.data.document.key, this.cod_doc);
                    await this.adicionarSignatarios(response.data.document.key);
                } else {
                    this.signPrepare = false;
                    this.error = response.error;
                }
            } catch (error) {
                this.signPrepare = false;
                this.error = "Não foi possível criar o documento para assinatura. (" + error.response + ")";
            }
        },
        async cancelDocument(uuidDoc) {
            this.cancelPrepare = true;
            var options = {
                method: 'PATCH',
                url: '/api/documents/' + uuidDoc + '/cancel',
                params: {
                    access_token: this.token
                },

                headers: {
                    'Content-Type': 'application/json'
                }
            };

            try {
                await this.$axios.request(options);
                this.cancelPrepare = false;
                this.cancelSuccess = true;
            } catch (error) {
                this.cancelPrepare = false;
                this.error = "Não foi possível cancelar o documento para assinatura. (" + error.response.data + ")";
            }
        },
        // async webHook(uuidDoc) {
        //     var options = {
        //         method: 'POST',
        //         url: '/api/hook',
        //         params: {
        //             tokenAPI: this.token,
        //             cryptKey: this.crypt,
        //             idDoc: uuidDoc
        //         },

        //         headers: {
        //             'Content-Type': 'application/json'
        //         },

        //         data: {
        //             url: this.url + 'webhook'
        //         }
        //     };

        //     try {
        //         await this.$axios.request(options);
        //     } catch (error) {
        //         this.error = "Não foi possível criar o WebHook do Documento. (" + error.response + ")";
        //     }
        // },
        async registraSolicitacao(contrato, uuidDoc, cod_doc) {

            var options = {
                method: 'POST',
                url: this.url_assinatura + 'registrarSolicitacao',
                headers: { 'Content-Type': 'multipart/form-data', 'x-api-key': 'e949f8ee3299e48ed653375017868b9b6d7a2c7b06191278eebaa9766ee9ab55' },
                data: {
                    cod_contrato: contrato,
                    uuid: uuidDoc,
                    cod_doc: cod_doc
                }
            }

            try {
                const response = await this.$axios.request(options);
                if (response.status == 200) {
                    this.cancel = true;
                } else {
                    this.error = response.error;
                }
            } catch (error) {
                this.error = "Não foi possível criar o documento para assinatura. (" + error.response + ")";
            }
        },
        async adicionarSignatarios(uuidDoc) {
            for (let i = 0; i < this.data.signers['novas'].length; i++) {
                var options = {
                    method: 'POST',
                    url: '/api/signers',
                    params: {
                        access_token: this.token,
                    },
                    headers: { 'Content-Type': 'application/json' },
                    data: {
                        signer: this.data.signers['novas'][i]
                    }
                };
                try {
                    const response = await this.$axios.request(options);
                    if (response.status == 201) {
                        this.enviarSignatarioPresencial(uuidDoc, response.data.signer.key);
                    } else {
                        this.error = response.error;
                    }
                } catch (error) {
                    this.error = "Não foi possível criar o documento para assinatura. (" + error.response + ")";
                }
            }
            for (let i = 0; i < this.data.signers.api.length; i++) {

                this.enviarSignatario(uuidDoc, this.data.signers['api'][i].key, this.data.signers['api'][i].role, this.data.signers['api'][i].pkey);
            }

        },
        async enviarSignatarioPresencial(uuidDoc, signerKey) {
            var options = {
                method: 'POST',
                url: '/api/lists',
                params: {
                    access_token: this.token,
                },
                headers: { 'Content-Type': 'application/json' },
                data: {
                    list: {
                        document_key: uuidDoc,
                        signer_key: signerKey,
                        sign_as: "sign"
                    }
                }
            };

            try {
                const response = await this.$axios.request(options);
                if (response.status == 201) {
                    var reqKey = response.data.list.request_signature_key;
                    this.notificaSignatarioPresencial(reqKey);
                } else {
                    this.error = response.error;
                }
            } catch (error) {
                this.error = "Não foi possível criar o documento para assinatura. (" + error.response + ")";
            }
        },
        async enviarSignatario(uuidDoc, signerKey, role, pkey) {
            let g = 1;
            if (role == 'validator')
                g = 3;
            var options = {
                params: {
                    access_token: this.token,
                },
                headers: { 'Content-Type': 'application/json' },
                data: {
                    list: {
                        document_key: uuidDoc,
                        signer_key: signerKey,
                        sign_as: role,
                        group: g
                    }
                }
            };

            var options = {
                method: 'POST',
                url: '/api/lists',
                params: {
                    access_token: this.token,
                },
                headers: { 'Content-Type': 'application/json' },
                data: {
                    list: {
                        document_key: uuidDoc,
                        signer_key: signerKey,
                        sign_as: "sign"
                    }
                }
            };

            try {
                const response = await this.$axios.request(options);
                if (response.status == 201) {
                    var reqKey = response.data.list.request_signature_key;
                    if (role == 'validator') {
                        this.notificaSignatario(reqKey, this.tipo);
                    }
                    this.assinar(pkey, reqKey);
                } else {
                    this.error = response.error;
                }
            } catch (error) {
                this.error = "Não foi possível criar o documento para assinatura. (" + error.response + ")";
            }
        },
        async assinar(pkey, reqKey) {
            function base64ToHex(str) {
                const raw = atob(str);
                let result = '';
                for (let i = 0; i < raw.length; i++) {
                    const hex = raw.charCodeAt(i).toString(16);
                    result += (hex.length === 2 ? hex : '0' + hex);
                }
                return result.toLowerCase();
            }

            var options = {
                method: 'POST',
                url: '/api/sign',
                params: {
                    access_token: this.token,
                },
                headers: { 'Content-Type': 'application/json' },
                data: {
                    request_signature_key: reqKey,
                    secret_hmac_sha256: base64ToHex(Base64.stringify(hmacSHA256(reqKey, pkey)))
                }
            };

            try {
                const response = await this.$axios.request(options);
                if (response.status == 201) {

                } else {
                    this.error = response.error;
                }
            } catch (error) {
                this.error = "Não foi possível criar o documento para assinatura. (" + error.response + ")";
            }
        },
        async notificaSignatarioPresencial(keyRequestSignature) {
            var options = {
                method: 'POST',
                url: '/api/send_presential_signature_request/email',
                params: {
                    access_token: this.token,
                },
                headers: { 'Content-Type': 'application/json' },
                data: {
                    request_signature_key: keyRequestSignature,
                    signature_host: this.data.host.signature_host,
                    recipient: this.data.host.recipient,
                    messages: this.data.host.messages
                }
            };

            try {
                const response = await this.$axios.request(options);
                if (response.status == 202) {
                    this.success = true;
                } else {
                    this.error = response.error;
                }
            } catch (error) {
                this.error = "Não foi possível criar o documento para assinatura. (" + error.response + ")";
            }
        },
    }
}
</script>
  