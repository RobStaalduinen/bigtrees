import moment from 'moment';

export function standardDate(inputDate) {
  return moment(inputDate).format('YYYY-MM-DD')
}
