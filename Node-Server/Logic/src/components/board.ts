export { Board, BoardData, hex_coord };

type hex_coord = [number, number];

interface BoardData {
  player_count: number;
  winning_score: number;
  traversable_hexes: hex_coord[];
  control_spots: hex_coord[][];
}

class Board {
  player_count: number;
  winning_score: number;
  traversable_hexes: hex_coord[];
  control_spots: hex_coord[][]; // -1 for unclaimed
  forts: hex_coord[] = [];
  poison: { [unit_id: string]: hex_coord }[] = [];

  constructor(boardData: BoardData) {
    this.player_count = boardData.player_count;
    this.winning_score = boardData.winning_score;
    this.traversable_hexes = boardData.traversable_hexes;
    this.control_spots = boardData.control_spots;
  }
}
