// TAN! Suporte: atualizacao pelas releases do GitHub da TAN, no lugar de api.rustdesk.com.
//
// Cada release tem a tag `tan-vX.Y.Z` e os exes `TAN-Suporte-X.Y.Z.exe` (cliente) e
// `TAN-Suporte-Tecnico-X.Y.Z.exe`. A versao deste build vem de TAN_VERSAO (sem o `tan-v`).
use hbb_common::{bail, log, ResultType};

// Se o repositorio mudar de dono (ex.: transferido ao Natanaelgpi), trocar aqui: o download so
// e aceito de github.com/REPO_DONO/REPO_NOME (updater.rs).
pub const REPO_DONO: &str = "7RayNNer";
pub const REPO_NOME: &str = "TANSuporte";
const RELEASE_MAIS_NOVA: &str =
    "https://api.github.com/repos/7RayNNer/TANSuporte/releases/latest";
const PREFIXO_TAG: &str = "tan-v";

pub fn versao() -> &'static str {
    match option_env!("TAN_VERSAO") {
        Some(v) if !v.is_empty() => v,
        _ => "0.0.0",
    }
}

fn nome_exe() -> &'static str {
    if hbb_common::config::is_incoming_only() {
        "TAN-Suporte"
    } else {
        "TAN-Suporte-Tecnico"
    }
}

/// Consulta a release mais nova e grava em SOFTWARE_UPDATE_URL a pagina dela
/// (`.../releases/tag/tan-vX.Y.Z`), ou vazio se ja estiver em dia. Bloqueante.
pub fn verificar() -> ResultType<()> {
    let client = crate::hbbs_http::create_http_client_with_url_strict(RELEASE_MAIS_NOVA)?;
    let resp = client
        .get(RELEASE_MAIS_NOVA)
        .header("User-Agent", "TAN-Suporte")
        .header("Accept", "application/vnd.github+json")
        .send()?;
    if !resp.status().is_success() {
        bail!("GitHub respondeu {}", resp.status());
    }
    let json: serde_json::Value = serde_json::from_slice(&resp.bytes()?)?;
    let tag = json["tag_name"].as_str().unwrap_or_default();
    let pagina = json["html_url"].as_str().unwrap_or_default();
    let Some(nova) = tag.strip_prefix(PREFIXO_TAG) else {
        bail!("tag inesperada: {}", tag);
    };
    let tem_nova = hbb_common::get_version_number(nova) > hbb_common::get_version_number(versao());
    log::info!("TAN update: atual {}, release {}", versao(), nova);
    if tem_nova {
        #[cfg(feature = "flutter")]
        {
            let mut m = std::collections::HashMap::new();
            m.insert("name", "check_software_update_finish");
            m.insert("url", pagina);
            if let Ok(data) = serde_json::to_string(&m) {
                let _ = crate::flutter::push_global_event(crate::flutter::APP_TYPE_MAIN, data);
            }
        }
        *crate::common::SOFTWARE_UPDATE_URL.lock().unwrap() = pagina.to_owned();
    } else {
        *crate::common::SOFTWARE_UPDATE_URL.lock().unwrap() = String::new();
    }
    Ok(())
}

/// Endereco do exe da release, a partir da pagina gravada por [`verificar`].
pub fn url_download(pagina: &str) -> Option<String> {
    let tag = pagina.rsplit('/').next()?;
    let nova = tag.strip_prefix(PREFIXO_TAG)?;
    Some(format!(
        "{}/{}-{}.exe",
        pagina.replace("/releases/tag/", "/releases/download/"),
        nome_exe(),
        nova
    ))
}
