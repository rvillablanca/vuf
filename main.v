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
	mut body_found := false
	mut all_month_div := &html.Tag{}

	for div in divs {
		if div.attributes['id'] == 'mes_all' {
			all_month_div = div
			body_found = true
			break
		}
	}
	if !body_found {
		return error('div with all uf values not found')
	}

	tbody := all_month_div.get_tags('tbody')
	if tbody.len == 0 {
		return error('tbody tag not found')
	}

	trs := tbody[0].get_tags('tr')
	if trs.len < now.day {
		return error('invalid length of rows when searching tr')
	}

	day_val := trs[now.day - 1]
	tds := day_val.get_tags('td')

	if tds.len < now.month {
		return error('invalid number of rows when searching td')
	}

	return tds[now.month - 1].text()
}
