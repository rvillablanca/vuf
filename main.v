module main

import time
import net.http
import net.html

fn main() {
	now := time.now()
	year := now.year
	uf_url := 'https://www.sii.cl/valores_y_fechas/uf/uf${year}.htm'
	resp := http.get(uf_url) or {
		eprint('unable to make request: ${err}')
		return
	}

	if resp.status() != http.Status.ok {
		eprintln('Invalid status code ${resp.status_code}')
		return
	}

	uf_val := retrieve_uf_from_body(resp.body) or {
		eprintln('an error happened: ${err}')
		return
	}

	println(uf_val)
}

fn retrieve_uf_from_body(body string) !string {
	now := time.now()
	obj := html.parse(body)
	divs := obj.get_tag('div')
	for div in divs {
		if div.attributes['id'] != '' && div.attributes['id'] == 'mes_all' {
			tbody := div.get_tags('tbody')
			if tbody.len > 0 {
				trs := tbody[0].get_tags('tr')
				if trs.len >= now.day {
					day_val := trs[now.day - 1]
					tds := day_val.get_tags('td')
					if tds.len >= now.month {
						return tds[now.month - 1].text()
					}
					return error('invalid number of rows when searching td')
				}
				return error('invalid length of rows when searching tr')
			}
			return error('tbody tag not found')
		}
	}
	return error('divs not found')
}
