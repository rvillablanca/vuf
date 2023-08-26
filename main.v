module main

import time
import net.http
import net.html
import os
import math

fn main() {
	uf_url := 'https://www.sii.cl/valores_y_fechas/uf/uf${time.now().year}.htm'
	resp := http.get(uf_url) or {
		eprint('unable to make request: ${err}')
		return
	}

	if resp.status() != http.Status.ok {
		eprintln('Invalid status code ${resp.status_code}')
		return
	}

	mut uf_val := retrieve_uf_from_body(resp.body) or {
		eprintln('an error happened: ${err}')
		return
	}
	uf_val = uf_val.replace('.', '').replace(',', '.')
	uf := int(math.round(uf_val.f32()))

	if os.args.len == 1 {
		println(uf)
		return
	}

	n := os.args[1].f32()
	if n == 0 {
		eprintln('invalid number')
		return
	}

	println('${uf} * ${n} = ${int(math.round(uf * n))}')
}

fn retrieve_uf_from_body(body string) !string {
	now := time.now()
	obj := html.parse(body)
	mut divs := obj.get_tags(name: 'div')

	divs = divs.filter(it.attributes['id'] == 'mes_all')
	if divs.len == 0 {
		return error('div with all uf values not found')
	}

	tbody := divs.first().get_tags('tbody')
	if tbody.len == 0 {
		return error('tbody tag not found')
	}

	trs := tbody.first().get_tags('tr')
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
