// https://stackoverflow.com/a/66072001

/******************************************************************
 * Converts e-Notation Numbers to Plain Numbers
 ******************************************************************
 * @function eToNumber(number)
 * @version  1.00
 * @param   {e nottation Number} valid Number in exponent format.
 *          pass number as a string for very large 'e' numbers or with large fractions
 *          (none 'e' number returned as is).
 * @return  {string}  a decimal number string.
 * @author  Mohsen Alyafei
 * @date    17 Jan 2020
 * Note: No check is made for NaN or undefined input numbers.
 *
 *****************************************************************/
export function eToNumber(num) {
	let sign = "";
	(num += "").charAt(0) == "-" && (num = num.substring(1), sign = "-");
	let arr = num.split(/[e]/ig);
	if (arr.length < 2) return sign + num;
	let dot = (.1).toLocaleString().substr(1, 1), n = arr[0], exp = +arr[1],
		w = (n = n.replace(/^0+/, '')).replace(dot, ''),
	  pos = n.split(dot)[1] ? n.indexOf(dot) + exp : w.length + exp,
	  L   = pos - w.length, s = "" + BigInt(w);
	  w   = exp >= 0 ? (L >= 0 ? s + "0".repeat(L) : r()) : (pos <= 0 ? "0" + dot + "0".repeat(Math.abs(pos)) + s : r());
	L= w.split(dot); if (L[0]==0 && L[1]==0 || (+w==0 && +s==0) ) w = 0; //** added 9/10/2021
	return sign + w;
	function r() {return w.replace(new RegExp(`^(.{${pos}})(.)`), `$1${dot}$2`)}
  }